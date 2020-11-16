require_dependency 'dokno/application_controller'

module Dokno
  class ArticleController < ApplicationController
    before_action :fetch_article, only: [:show, :edit, :update, :panel]

    def show
      return redirect_to root_path if @article.blank?
    end

    def new
      @category_ids = [] << params[:category_id].to_i
      @article = Dokno::Article.new
    end

    def edit
      @category_ids = @article&.categories.pluck(:id)
    end

    def create
      article = Dokno::Article.create!(article_params)
      article.categories = Dokno::Category.where(id: params[:category_id]) if params[:category_id].present?
      redirect_to article_path article
    end

    def update
      @article.update!(article_params)
      @article.categories = Dokno::Category.where(id: params[:category_id])
      redirect_to article_path @article
    end

    # Ajax-fetched slide-in article panel for the host app
    def panel
      render json: @article&.host_panel_hash, layout: false
    end

    private

    def article_params
      params.permit(:slug, :title, :summary, :markdown)
    end

    def fetch_article
      @article = Dokno::Article.find_by(slug: params[:slug].strip)    if params[:slug].present?
      @article = Dokno::Article.find_by(id: params[:article_id].to_i) if @article.blank?
    end
  end
end