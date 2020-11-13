require_dependency 'dokno/application_controller'

module Dokno
  class CategoryController < ApplicationController
    def show
      category_id = params[:category_id].to_i
      @category = Dokno::Category.find_by(id: category_id) if category_id.positive?
      @articles = if @category.present?
                    @category.articles_in_branch
                  else
                    Dokno::Article.uncategorized
                  end
    end

    def new
      @parent_category_id = params[:parent_category_id].to_i
      @category = Dokno::Category.new
    end

    def create
      category = Dokno::Category.create!(name: params[:name], category_id: params[:category_id])
      redirect_to category_path(category)
    end

    def edit
      @category = Dokno::Category.find_by(id: params[:category_id].to_i)
      return redirect_to category_path if @category.blank?
    end

    def update
      category = Dokno::Category.find_by(id: params[:id].to_i)
      return redirect_to category_path if category.blank?
      return redirect_to category_path if category.id == params[:category_id].to_i

      category.update!(name: params[:name], category_id: params[:category_id])
      redirect_to category_path(category)
    end
  end
end