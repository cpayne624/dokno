require_dependency 'dokno/application_controller'

module Dokno
  class CategoriesController < ApplicationController
    before_action :fetch_category, only: [:show, :edit, :update]

    def index
      @articles = Dokno::Article.uncategorized
    end

    def show
      return redirect_to root_path if @category.blank?
      @articles = @category.articles_in_branch
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
  end
end