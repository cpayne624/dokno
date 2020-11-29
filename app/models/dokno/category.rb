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

    validates :name, presence: true, uniqueness: true
    validate :circular_parent_check

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

      crumbs.join(' / ')
    end

    # All Articles in the Category, including all child Categories
    def articles_in_branch
      Dokno::Article
        .select('
          dokno_articles.id,
          dokno_articles.active,
          dokno_articles.slug,
          dokno_articles.title,
          dokno_articles.summary,
          dokno_articles.markdown
        ')
        .joins(:categories)
        .where(dokno_categories: { id: self.class.branch(parent_category_id: id).pluck(:id) })
        .order('active DESC, title')
        .all.uniq
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

    # HTML markup for Category SELECT field OPTION lists
    def self.select_option_markup(selected_category_ids: nil, exclude_category_id: nil)
      selected_category_ids = selected_category_ids&.map(&:to_i)
      breadcrumbs = all
        .reject { |category| category.id == exclude_category_id.to_i }
        .map { |category| { id: category.id, name: category.breadcrumb } }
      breadcrumbs.sort_by { |category_hash| category_hash[:name] }.map do |category_hash|
        select = selected_category_ids&.include?(category_hash[:id].to_i)
        %(<option value="#{category_hash[:id]}" #{'selected="selected"' if select}>#{category_hash[:name]}</option>)
      end.join
    end

    private

    # Never allow setting of parent to self
    def circular_parent_check
      return unless persisted? && id.to_i == category_id.to_i

      errors.add(:category_id, "can't set parent to self")
    end
  end
end
