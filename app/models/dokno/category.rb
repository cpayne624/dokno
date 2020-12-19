module Dokno
  class Category < ApplicationRecord
    belongs_to :parent, class_name: 'Dokno::Category', primary_key: 'id', foreign_key: 'category_id', inverse_of: :children, optional: true
    has_many :children, class_name: 'Dokno::Category', primary_key: 'id', foreign_key: 'category_id', inverse_of: :parent, dependent: :nullify

    has_and_belongs_to_many :articles

    before_validation :set_code
    validates :name, :code, presence: true, uniqueness: true
    validate :circular_parent_check

    scope :alpha_order, -> { order(:name) }

    def breadcrumb(**args)
      crumbs = [(category_link(self, args) unless args[:hide_self])]
      parent_category_id = category_id

      loop do
        break if parent_category_id.blank?

        parent_category = Category.find(parent_category_id)
        crumbs.prepend category_link(parent_category, args)
        parent_category_id = parent_category.category_id
      end

      crumbs.compact.join("&nbsp;&nbsp;>&nbsp;&nbsp;").html_safe
    end

    def category_link(category, args={})
      %(<a href="#{article_index_path(category.code)}?search_term=#{CGI.escape(args[:search_term].to_s)}&order=#{CGI.escape(args[:order].to_s)}">#{category.name}</a>)
    end

    # All Articles in the Category, including all child Categories
    def articles_in_branch(order: :updated)
      records = Article
        .includes(:categories_dokno_articles, :categories)
        .joins(:categories)
        .where(dokno_categories: { id: self.class.branch(parent_category_id: id).pluck(:id) })

      Article.apply_sort(records, order: order)
    end

    def branch
      self.class.branch(parent_category_id: id)
    end

    # Used to invalidate the fragment cache of the hierarchical category select options
    def self.cache_key
      [maximum(:updated_at), Article.maximum(:updated_at)].compact.max
    end

    # The given Category and all child Categories. Useful for filtering associated articles.
    def self.branch(parent_category_id:, at_top: true)
      return if parent_category_id.blank?

      categories = []
      parent_category = find(parent_category_id)
      child_categories = parent_category.children.to_a

      child_categories.each do |child_category|
        categories << child_category << branch(parent_category_id: child_category.id, at_top: false)
      end

      categories.prepend parent_category if at_top
      categories.flatten
    end

    def self.select_option_markup(selected_category_codes: nil, context_category: nil, level: 0)
      return '' if level.positive? && context_category.blank?

      options = []
      level_categories = where(category_id: context_category&.id).alpha_order
      level_categories.each do |category|
        options << option_markup(category: category, selected_category_codes: selected_category_codes, level: level)
        options << select_option_markup(selected_category_codes: selected_category_codes, context_category: category, level: (level + 1))
      end

      options.join
    end

    private

    def self.option_markup(category:, selected_category_codes:, level: 0)
      selected = selected_category_codes&.include?(category.code)
      article_count = category.articles_in_branch.size
      %(<option value="#{category.code}" #{'selected="selected"' if selected}>#{('&nbsp;&nbsp;' * level)}#{category.name}#{' (' + article_count.to_s + ')' if article_count.positive?}</option>)
    end

    # Never allow setting of parent to self
    def circular_parent_check
      return unless persisted? && id.to_i == category_id.to_i

      errors.add(:category_id, "can't set parent to self")
    end

    def set_code
      return unless name.present?

      self.code = name.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
    end
  end
end
