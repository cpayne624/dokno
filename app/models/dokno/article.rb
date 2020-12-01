require 'diffy'
require 'redcarpet'

module Dokno
  class Article < ApplicationRecord
    include Engine.routes.url_helpers
    include ActionView::Helpers::DateHelper

    has_and_belongs_to_many :categories
    has_many :logs, dependent: :destroy
    has_many :article_slugs, dependent: :destroy

    validates :slug, :title, presence: true
    validates :slug, length: { in: 2..20 }
    validates :title, length: { in: 5..255 }
    validate :unique_slug_check

    before_save :log_changes
    before_save :track_slug

    scope :alpha_order,   -> { order(active: :desc, title: :asc) }
    scope :view_order,    -> { order(active: :desc, views: :desc, title: :asc) }
    scope :newest_order,  -> { order(active: :desc, created_at: :desc, title: :asc) }
    scope :updated_order, -> { order(active: :desc, updated_at: :desc, title: :asc) }

    attr_accessor :editor_username

    MARKDOWN_PARSER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

    def reading_time
      minutes_decimal = (("#{summary} #{markdown}".squish.scan(/[\w-]+/).size) / 200.0)
      approx_minutes  = minutes_decimal.ceil
      return '' unless approx_minutes > 1

      "~ #{approx_minutes} minutes"
    end

    def markdown
      super || ''
    end

    def markdown_parsed
      self.class.parse_markdown markdown
    end

    # Breadcrumbs for all associated categories; limits to sub-categories if in the context of a category
    def category_name_list(context_category_id: nil, order: nil, search_term: nil)
      return '' if categories.blank?

      names = Category
        .joins(articles_dokno_categories: :article)
        .where(dokno_articles_categories: { article_id: id })
        .all
        .map do |category|
          "<a class='underline' href='#{article_index_path(category.code)}?search_term=#{CGI.escape(search_term.to_s)}&order=#{CGI.escape(order.to_s)}'>#{category.name}</a>" if context_category_id != category.id
        end.compact

      return '' if names.blank?

      list = (context_category_id.present? ? 'In other category' : 'Category').pluralize(names.length)
      list += ': ' + names.to_sentence
      list.html_safe
    end

    # Hash returned for the ajax-fetched slide-in article panel for the host app
    def host_panel_hash
      footer = %Q(
        <p><a href="#{article_path(slug)}" target="_blank" title="Open in the knowledgebase">Print / email / edit / delete</a></p>
        <p>#{categories.present? ? category_name_list : 'Uncategorized'}</p>
        <p>Knowledgebase slug : #{slug}</p>
        <p>Last updated : #{time_ago_in_words(updated_at)} ago</p>
      )

      footer += "<p>Contributors : #{contributors}</p>" if contributors.present?

      title_markup = %Q(
        <span title="Open full article page" onclick="window.open('#{article_path(slug)}');">#{title}</span>
      )

      unless active
        title_markup = title_markup.prepend(
          %Q(
            <div id="article-deprecated-alert">
              This article is no longer active
            </div>
          )
        )
      end

      {
        title:    title_markup,
        id:       id,
        slug:     slug,
        summary:  summary.presence || (markdown_parsed.present? ? '' : 'No content'),
        markdown: markdown_parsed,
        footer:   footer
      }
    end

    def permalink(base_url)
      "#{base_url}#{article_path(slug)}"
    end

    def contributors
      logs
        .where('meta LIKE ? OR meta LIKE ?', '%Markdown%', '%Summary%')
        .pluck(:username)
        .reject(&:blank?)
        .uniq
        .sort
        .to_sentence
    end

    # All uncategorized Articles
    def self.uncategorized(order: :updated)
      records = Article
        .includes(:categories_dokno_articles, :categories)
        .left_joins(:categories)
        .where(active: true, dokno_categories: { id: nil })

      records = records.updated_order if order == :updated
      records = records.newest_order  if order == :newest
      records = records.view_order    if order == :views
      records = records.alpha_order   if order == :alpha

      records
    end

    def self.parse_markdown(content)
      ActionController::Base.helpers.sanitize(
        MARKDOWN_PARSER.render(content),
        tags:       Dokno.config.tag_whitelist,
        attributes: Dokno.config.attr_whitelist
      )
    end

    def self.template
      template_file = File.join(Rails.root, 'config', 'dokno_template.md')
      return unless File.exist?(template_file)

      File.read(template_file).to_s
    end

    def self.search(term:, category_id: nil, order: :updated)
      records = where(
        'LOWER(title) LIKE :search_term OR '\
        'LOWER(summary) LIKE :search_term OR '\
        'LOWER(markdown) LIKE :search_term OR '\
        'LOWER(slug) LIKE :search_term',
        search_term: "%#{term.downcase}%"
      )
      .includes(:categories_dokno_articles)
      .includes(:categories)

      records = records.updated_order if order == :updated
      records = records.newest_order  if order == :newest
      records = records.view_order    if order == :views
      records = records.alpha_order   if order == :alpha

      return records unless category_id.present?

      # Scope to the context category and its children
      records
        .joins(:categories)
        .where(
          dokno_categories: {
            id: Category.branch(parent_category_id: category_id).pluck(:id)
          }
        )
    end

    private

    # Ensure there isn't another Article with the same slug
    def unique_slug_check
      slug_used = self.class.where(slug: slug&.strip).where.not(id: id).exists?
      slug_used ||= ArticleSlug.where(slug: slug&.strip).exists?
      return unless slug_used

      errors.add(:slug, "must be unique, #{slug} has already been used")
    end

    def track_slug
      return unless slug_changed?

      old_slug = changes['slug'].first
      ArticleSlug.where(slug: old_slug&.strip, article_id: id).first_or_create
    end

    def log_changes
      return if changes.blank?

      meta_changes    = changes.with_indifferent_access.slice(:slug, :title, :active)
      content_changes = changes.with_indifferent_access.slice(:summary, :markdown)

      meta = []
      meta_changes.each_pair do |field, values|
        action = persisted? ? "changed from '#{values.first}' to" : "entered as"
        meta << "#{field.capitalize} #{action} '#{values.last}'"
      end

      content = { before: '', after: '' }
      content_changes.each_pair do |field, values|
        meta << "#{field.capitalize} was #{persisted? ? 'changed' : 'entered'}"
        content[:before] += values.first.to_s + ' '
        content[:after]  += values.last.to_s + ' '
      end

      return unless meta.present?

      diff = Diffy::SplitDiff.new(content[:before].squish, content[:after].squish, format: :html)
      logs << Log.new(username: editor_username, meta: meta.to_sentence, diff_left: diff.left, diff_right: diff.right)
    end
  end
end
