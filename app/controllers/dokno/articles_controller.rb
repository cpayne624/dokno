require_dependency 'dokno/application_controller'

module Dokno
  class ArticlesController < ApplicationController
    before_action :authorize,     except: [:show, :panel]
    before_action :fetch_article, only: [:show, :edit, :panel, :status]
    before_action :update_views,  only: [:show]

    def show
      redirect_to root_path if @article.blank?
      @search_term = params[:search_term]
    end

    def new
      @article        = Article.new
      @template       = Article.template
      @category_codes = [] << params[:category_code]
    end

    def edit
      return redirect_to root_path if @article.blank?
      @category_codes = @article.categories.pluck(:code)
    end

    def create
      @article = Article.new(article_params)
      set_editor_username

      if @article.save
        @article.categories = Category.where(code: params[:category_code]) if params[:category_code].present?
        redirect_to article_path @article.slug
      else
        @category_codes = params[:category_code]
        render :new
      end
    end

    def update
      @article = Article.find_by(id: params[:id].to_i)
      return redirect_to root_path if @article.blank?

      set_editor_username

      if @article.update(article_params)
        @article.categories = Category.where(code: params[:category_code])
        redirect_to article_path @article.slug
      else
        @category_codes = params[:category_code]
        render :edit
      end
    end

    def destroy
      Article.find(params[:id].to_i).destroy!
      render json: {}, layout: false
    end

    # Ajax-fetched slide-in article panel for the host app
    def panel
      render json: @article&.host_panel_hash, layout: false
    end

    # Ajax-fetched preview of article content from article form
    def preview
      content = Article.parse_markdown params['markdown']
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
        locals: { article: Article.find_by(id: params[:article_id].to_i) }, layout: false
    end

    private

    def article_params
      params.permit(:slug, :title, :summary, :markdown)
    end

    def fetch_article
      # Find by slug
      slug = (params[:slug].presence || params[:id]).to_s.strip
      @article = Article.find_by(slug: slug)
      return if @article.present?

      # Find by an old slug that has been changed (redirect to current slug)
      old_slug = ArticleSlug.find_by(slug: slug)
      return redirect_to article_path(old_slug.article.slug) if old_slug.present?

      # Find by ID (redirect to slug)
      article = Article.find_by(id: params[:id].to_i)
      return redirect_to article_path(article.slug) if article.present?
    end

    def set_editor_username
      @article&.editor_username = username
    end

    def update_views
      return unless @article.present?
      return unless (@article.last_viewed_at || 2.minutes.ago) < 1.minute.ago

      # No callbacks here, intentionally
      @article.update_columns(views: (@article.views + 1), last_viewed_at: Time.now.utc)
    end
  end
end
