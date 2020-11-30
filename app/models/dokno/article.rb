require 'diffy'
require 'redcarpet'

module Dokno
  class Article < ApplicationRecord
    include Dokno::Engine.routes.url_helpers
    include ActionView::Helpers::DateHelper

    has_and_belongs_to_many :categories
    has_many :logs, dependent: :destroy

    validates :slug, :title, presence: true
    validates :slug, length: { in: 2..12 }
    validates :title, length: { in: 5..255 }
    validate :unique_slug_check

    before_save :log_changes

    attr_accessor :editor_username

    MARKDOWN_PARSER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

    def markdown
      super || ''
    end

    def markdown_parsed
      self.class.parse_markdown markdown
    end

    def category_name_list
      return '' if categories.blank?

      names = categories.pluck(:name)
      list = 'Category'.pluralize(names.length)
      list + ': ' + names.to_sentence
    end

    # Hash returned for the ajax-fetched slide-in article panel for the host app
    def host_panel_hash
      footer = %Q(
        #{Dokno::ICON}
        <p>#{categories.present? ? category_name_list : 'Uncategorized'}</p>
        <p>Last updated: #{time_ago_in_words(updated_at)} ago</p>
        <p>#{Dokno.config.app_name} Knowledgebase article slug : #{slug}</p>
        <p><a href="#{root_path}" target="_blank" title="Open the full #{CGI.escape Dokno.config.app_name} knowledgebase site">Knowledgebase site</a></p>
      )

      title_markup = %Q(
        <span>#{title}</span>
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
        summary:  summary,
        markdown: markdown_parsed,
        footer:   footer
      }
    end

    def permalink(base_url)
      "#{base_url}#{articles_path}/#{slug}"
    end

    # All uncategorized Articles
    def self.uncategorized
      Dokno::Article.left_joins(:categories).where(active: true, dokno_categories: {id: nil}).order(:title).all
    end

    def self.parse_markdown(content)
      ActionController::Base.helpers.sanitize(
        MARKDOWN_PARSER.render(content),
        tags:       Dokno.config.tag_whitelist,
        attributes: Dokno.config.attr_whitelist
      )
    end

    private

    # Ensure there isn't another Article with the same slug
    def unique_slug_check
      return unless self.class.where(slug: slug&.strip).where.not(id: id).exists?

      errors.add(:slug, "must be unique, #{slug} already exists")
    end

    def log_changes
      return if changes.blank?
      return unless persisted?

      meta_changes    = changes.with_indifferent_access.slice(:slug, :title, :active)
      content_changes = changes.with_indifferent_access.slice(:summary, :markdown)

      meta = []
      meta_changes.each_pair do |field, values|
        meta << "#{field.capitalize} changed from '#{values.first}' to '#{values.last}'"
      end

      content = { before: '', after: '' }
      content_changes.each_pair do |field, values|
        meta << "#{field.capitalize} was changed"
        content[:before] += values.first.to_s + ' '
        content[:after]  += values.last.to_s + ' '
      end

      return unless meta.present?

      diff = Diffy::SplitDiff.new(content[:before].squish, content[:after].squish, format: :html)
      logs << Dokno::Log.new(username: editor_username, meta: meta.to_sentence, diff_left: diff.left, diff_right: diff.right)
    end
  end
end
