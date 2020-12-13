module Dokno
  class Category < ApplicationRecord
    belongs_to :parent,
      class_name: 'Dokno::Category',
      primary_key: 'id',
      foreign_key: 'category_id',
      optional: true,
      inverse_of: :children
    has_many :children,
      class_name: 'Dokno::Category',
      primary_key: 'id',
      foreign_key: 'category_id',
      dependent: :nullify,
      inverse_of: :parent

    has_and_belongs_to_many :articles

    validates :name, :code, presence: true, uniqueness: true
    validate :circular_parent_check

    before_validation :set_code

    scope :alpha_order, -> { order(:name) }

    # The display breadcrumb for the Category
    def breadcrumb
      crumbs = [name]
      parent_category_id = category_id

      loop do
        break if parent_category_id.blank?

        parent_category = self.class.find(parent_category_id)
        crumbs.prepend parent_category.name
        parent_category_id = parent_category.category_id
      end

      crumbs.join(' > ')
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

    def self.select_option_markup(selected_category_codes: nil, exclude_category_id: nil, context_category: nil, level: 0)
      return '' if level.positive? && context_category.blank?

      options = []
      level_categories = where(category_id: context_category&.id).alpha_order

      level_categories.each do |category|
        options << option_markup(
          category:                category,
          selected_category_codes: selected_category_codes,
          exclude_category_id:     exclude_category_id,
          level:                   level
        )

        options << select_option_markup(
          selected_category_codes: selected_category_codes,
          exclude_category_id:     exclude_category_id,
          context_category:        category,
          level:                   (level + 1)
        )
      end

      options.join
    end

    private

    def self.option_markup(category:, selected_category_codes:, exclude_category_id:, level: 0)
      return '' if category.id == exclude_category_id

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
