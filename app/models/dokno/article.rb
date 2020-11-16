require 'redcarpet'

module Dokno
  class Article < ApplicationRecord
    include ActionView::Helpers::SanitizeHelper

    has_and_belongs_to_many :categories

    validates :slug, :title, presence: true
    validate :unique_slug_check

    MARKDOWN_PARSER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

    def markdown
      super || ''
    end

    def markdown_parsed
      sanitize MARKDOWN_PARSER.render(markdown.gsub(URI.regexp, '<a target="_blank" href="\0">\0</a>')), tags: Dokno.config.tag_whitelist, attributes: Dokno.config.attr_whitelist
    end

    def category_name_list
      names = categories.pluck(:name)
      list = 'Category'.pluralize(names.length)
      list + ': ' + names.to_sentence
    end

    # Hash returned for the ajax-fetched slide-in article panel for the host app
    def host_panel_hash
      {
        id:         id,
        slug:       slug,
        title:      title,
        summary:    summary,
        markdown:   markdown_parsed,
        categories: category_name_list
      }
    end

    # (ActiveRecord::Relation) Returns all uncategorized Articles
    def self.uncategorized
      Dokno::Article.left_joins(:categories).where(dokno_categories: {id: nil}).order(:title).all
    end

    private

    # Ensure there isn't another Article with the same slug
    def unique_slug_check
      return unless self.class.where(slug: slug&.strip).where.not(id: id).exists?

      errors.add(:slug, "must be unique, #{slug} already exists")
    end
  end
end
