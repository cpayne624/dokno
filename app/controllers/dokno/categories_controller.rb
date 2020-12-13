require_dependency 'dokno/application_controller'

module Dokno
  class CategoriesController < ApplicationController
    before_action :authorize,      except: [:index]
    before_action :fetch_category, only: [:index, :edit, :update]

    def index
      @search_term = params[:search_term]
      @order       = params[:order]&.strip
      @order       = 'updated' unless %w(updated newest views alpha).include?(@order)

      articles = if request.path.include? up_for_review_path
                   Article.up_for_review(order: @order&.to_sym)
                 elsif @search_term.present?
                   Article.search(term: @search_term, category_id: @category&.id, order: @order&.to_sym)
                 elsif @category.present?
                   @category.articles_in_branch(order: @order&.to_sym)
                 else
                   Article.uncategorized(order: @order&.to_sym)
                 end

      @articles = paginate(articles)
    end

    def new
      @category             = Category.new
      @parent_category_code = params[:parent_category_code]
    end

    def edit
      return redirect_to root_path if @category.blank?
      @parent_category_code = @category.parent&.code
    end

    def create
      @category = Category.new(name: params[:name], parent: Category.find_by(code: params[:parent_category_code]))

      if @category.save
        flash[:green] = 'Category was created'
        redirect_to article_index_path(@category.code)
      else
        flash.now[:red]       = 'Category could not be created'
        @parent_category_code = params[:parent_category_code]
        render :new
      end
    end

    def update
      return redirect_to root_path if @category.blank?

      if @category.update(name: params[:name], parent: Category.find_by(code: params[:parent_category_code]))
        flash[:green] = 'Category was updated'
        redirect_to article_index_path(@category.code)
      else
        flash.now[:red]       = 'Category could not be updated'
        @parent_category_code = params[:parent_category_code]
        render :edit
      end
    end

    def destroy
      Category.find(params[:id].to_i).destroy!

      flash[:green] = 'Category was deleted'
      render json: {}, layout: false
    end

    private

    def fetch_category
      @category = Category.find_by(code: params[:cat_code].to_s.strip)
      @category = Category.find_by(id: params[:id].to_i) if @category.blank?
    end
  end
end
