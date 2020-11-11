require_dependency 'dokno/application_controller'

module Dokno
  class ArticleController < ApplicationController
    def show
      article_id = params[:article_id]
      return redirect_to root_path if article_id.blank?

      @article = Dokno::Article.find_by(id: article_id.to_i)
      return redirect_to root_path if @article.blank?
    end
  end
end