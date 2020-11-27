require_dependency 'dokno/application_controller'

module Dokno
  class CategoriesController < ApplicationController
    before_action :fetch_category, only: [:index, :edit, :update]

    def index
      search if params[:search_term].present?
      @articles = @category&.articles_in_branch if @articles.nil?
      @articles = Dokno::Article.uncategorized if @articles.nil?
    end

    def new
      @category = Dokno::Category.new
      @parent_category_id = params[:parent_category_id]
    end

    def edit
      return redirect_to category_path if @category.blank?
      @parent_category_id = @category.category_id
    end

    def create
      @category = Dokno::Category.new(category_params)

      if @category.save
        redirect_to category_path @category
      else
        @parent_category_id = params[:category_id]
        render :new
      end
    end

    def update
      return redirect_to category_path if @category.blank?

      if @category.update(category_params)
        redirect_to category_path @category
      else
        @parent_category_id = params[:category_id]
        render :edit
      end
    end

    private

    def category_params
      params.permit(:name, :category_id)
    end

    def fetch_category
      @category = Dokno::Category.find_by(id: params[:id].to_i)
    end

    def search
      @search_term = params[:search_term].to_s.strip
      @articles = Dokno::Article
        .where(
          'LOWER(title) LIKE :search_term OR '\
          'LOWER(summary) LIKE :search_term OR '\
          'LOWER(markdown) LIKE :search_term OR '\
          'LOWER(slug) LIKE :search_term',
          search_term: "%#{@search_term.downcase}%"
        )
        .order('updated_at DESC')

      fetch_category
      return if @category.blank?

      # Search within the specified category and all children categories within it
      category_ids = Category.branch(parent_category_id: @category.id).pluck(:id)
      @articles = @articles.joins(:categories).where(dokno_categories: {id: category_ids}).uniq
    end
  end
end
