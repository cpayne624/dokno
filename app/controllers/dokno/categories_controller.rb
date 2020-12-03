require_dependency 'dokno/application_controller'

module Dokno
  class CategoriesController < ApplicationController
    before_action :authorize,      except: [:index]
    before_action :fetch_category, only: [:index, :edit, :update]

    def index
      @search_term = params[:search_term]
      @order       = params[:order]&.strip
      @order       = 'updated' unless %w(updated newest views alpha).include?(@order)

      articles = if @search_term.present?
                   Article.search(term: @search_term, category_id: @category&.id, order: @order&.to_sym)
                 elsif @category.present?
                   @category.articles_in_branch(order: @order&.to_sym)
                 else
                   Article.uncategorized(order: @order&.to_sym)
                 end

      @articles = paginate(articles)
    end

    def new
      @category = Category.new
      @parent_category_id = params[:parent_category_id]
    end

    def edit
      return redirect_to root_path if @category.blank?
      @parent_category_id = @category.category_id
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to "#{root_path}?id=#{@category.id}"
      else
        @parent_category_id = params[:category_id]
        render :new
      end
    end

    def update
      return redirect_to root_path if @category.blank?

      if @category.update(category_params)
        redirect_to "#{root_path}?id=#{@category.id}"
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
      @category = Category.find_by(code: params[:cat_code].to_s.strip)
      @category = Category.find_by(id: params[:id].to_i) if @category.blank?
    end
  end
end
