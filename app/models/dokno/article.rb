require 'redcarpet'

module Dokno
  class Article < ApplicationRecord
    include Dokno::Engine.routes.url_helpers

    has_and_belongs_to_many :categories

    validates :slug, :title, presence: true
    validates :slug, length: { in: 2..12 }
    validates :title, length: { in: 5..255 }
    validate :unique_slug_check

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
        <p>Last updated: #{updated_at}</p>
        <p>#{Dokno.config.app_name} Knowledgebase article slug : #{slug}</p>
      )

      {
        title:    "<span>#{title}</span>",
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
      Dokno::Article.left_joins(:categories).where(dokno_categories: {id: nil}).order(:title).all
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
  end
end
