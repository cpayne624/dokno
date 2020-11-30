require_dependency 'dokno/application_controller'

module Dokno
  class ArticlesController < ApplicationController
    before_action :authorize, except: [:show, :panel]
    before_action :fetch_article, only: [:show, :edit, :panel, :status]

    def show
      return redirect_to root_path if @article.blank?
    end

    def new
      @article      = Dokno::Article.new
      @template     = Dokno::Article.template
      @category_ids = [] << params[:category_id]
    end

    def edit
      return redirect_to root_path if @article.blank?
      @category_ids = @article.categories.pluck(:id)
    end

    def create
      @article = Dokno::Article.new(article_params)
      set_editor_username

      if @article.save
        @article.categories = Dokno::Category.where(id: params[:category_id]) if params[:category_id].present?
        redirect_to article_path @article
      else
        @category_ids = params[:category_id]
        render :new
      end
    end

    def update
      @article = Dokno::Article.find_by(id: params[:id].to_i)
      return redirect_to root_path if @article.blank?

      set_editor_username

      if @article.update(article_params)
        @article.categories = Dokno::Category.where(id: params[:category_id])
        redirect_to article_path @article
      else
        @category_ids = params[:category_id]
        render :edit
      end
    end

    def destroy
      Dokno::Article.find(params[:id].to_i).destroy!
      render json: {}, layout: false
    end

    # Ajax-fetched slide-in article panel for the host app
    def panel
      render json: @article&.host_panel_hash, layout: false
    end

    # Ajax-fetched preview of article content from article form
    def preview
      content = Dokno::Article.parse_markdown params['markdown']
      render json: { parsed_content: content.presence || 'Nothing to preview' }, layout: false
    end

    # Ajax-invoked article status changing
    def status
      set_editor_username
      @article.update!(active: params[:active])
      render json: {}, layout: false
    end

    # Ajax-fetched article change log
    def article_log
      render partial: '/partials/logs',
        locals: {
          category: Dokno::Category.find_by(id: params[:category_id].to_i),
          article:  Dokno::Article.find_by(id: params[:article_id].to_i)
        }, layout: false
    end

    private

    def article_params
      params.permit(:slug, :title, :summary, :markdown)
    end

    def fetch_article
      slug = (params[:slug].presence || params[:id]).to_s.strip
      @article = Dokno::Article.find_by(slug: slug)
      return if @article.present?

      @article = Dokno::Article.find_by(id: params[:id].to_i)
      return redirect_to article_path(@article.slug) if @article.present?
    end

    def set_editor_username
      @article&.editor_username = username
    end
  end
end
