require 'redcarpet'

module Dokno
  class Article < ApplicationRecord
    include ActionView::Helpers::SanitizeHelper

    has_and_belongs_to_many :categories

    validates :slug, :title, presence: true

    MARKDOWN_PARSER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

    def markdown
      super || ''
    end

    def markdown_parsed
      sanitize MARKDOWN_PARSER.render(markdown), tags: Dokno.config.tag_whitelist, attributes: Dokno.config.attr_whitelist
    end

    def category_name_list
      names = categories.pluck(:name)
      list = 'Category'.pluralize(names.length)
      list + ': ' + names.to_sentence
    end

    # (ActiveRecord::Relation) Returns all uncategorized Articles
    def self.uncategorized
      Dokno::Article.left_joins(:categories).where(dokno_categories: {id: nil}).order(:title).all
    end
  end
end
