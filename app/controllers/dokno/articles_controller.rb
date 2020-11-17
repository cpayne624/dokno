require_dependency 'dokno/application_controller'

module Dokno
  class ArticlesController < ApplicationController
    before_action :fetch_article, only: [:show, :edit, :update, :panel]

    def show
      return redirect_to root_path if @article.blank?
    end

    def new
      @article = Dokno::Article.new
      @category_ids = [] << params[:category_id]
    end

    def edit
      return redirect_to root_path if @article.blank?
      @category_ids = @article&.categories.pluck(:id)
    end

    def create
      @article = Dokno::Article.new(article_params)

      if @article.save
        @article.categories = Dokno::Category.where(id: params[:category_id]) if params[:category_id].present?
        redirect_to article_path @article
      else
        @category_ids = params[:category_id]
        render :new
      end

    end

    def update
      return redirect_to root_path if @article.blank?

      if @article.update(article_params)
        @article.categories = Dokno::Category.where(id: params[:category_id])
        redirect_to article_path @article
      else
        @category_ids = params[:category_id]
        render :edit
      end
    end

    # Ajax-fetched slide-in article panel for the host app
    def panel
      render json: @article&.host_panel_hash, layout: false
    end

    # Ajax-fetched preview of article content from article form
    def preview
      content = Dokno::Article.parse_markdown params['markdown']
      render json: { parsed_content: content }, layout: false
    end

    private

    def article_params
      params.permit(:slug, :title, :summary, :markdown)
    end

    def fetch_article
      @article = Dokno::Article.find_by(id: params[:id].to_i)
      @article = Dokno::Article.find_by(slug: params[:slug].strip) if @article.blank? && params[:slug].present?
    end
  end
end