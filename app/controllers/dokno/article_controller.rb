require_dependency 'dokno/application_controller'

module Dokno
  class ArticleController < ApplicationController
    def show
      article_id = params[:article_id]
      return redirect_to root_path if article_id.blank?

      @article = Dokno::Article.find_by(id: article_id.to_i)
      return redirect_to root_path if @article.blank?
    end

    def new
      @category_id = params[:category_id].to_i
      @article = Dokno::Article.new
    end

    def create
      category_ids = params[:category_id]
      article = Dokno::Article.create!(article_params)
      article.categories = Dokno::Category.where(id: category_ids)
      redirect_to article_path article
    end

    private

    def article_params
      params.permit(:slug, :title, :summary, :markdown)
    end
  end
end