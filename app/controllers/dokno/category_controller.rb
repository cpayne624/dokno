require_dependency 'dokno/application_controller'

module Dokno
  class CategoryController < ApplicationController
    before_action :fetch_category, only: [:show, :edit, :update]

    def show
      @articles = @category.present? ? @category.articles_in_branch : Dokno::Article.uncategorized
    end

    def new
      @parent_category_id = params[:parent_category_id].to_i
      @category = Dokno::Category.new
    end

    def create
      category = Dokno::Category.create!(category_params)
      redirect_to category_path category
    end

    def edit
      return redirect_to category_path if @category.blank?
    end

    def update
      return redirect_to category_path if @category.blank?

      # Never allow setting of parent to self
      # return redirect_to category_path if @category.id == params[:category_id].to_i

      category.update!(category_params)
      redirect_to category_path category
    end

    private

    def category_params
      params.permit(:name, :category_id)
    end

    def fetch_category
      @category = Dokno::Category.find_by(id: params[:category_id].to_i) if params[:category_id].present?
    end
  end
end