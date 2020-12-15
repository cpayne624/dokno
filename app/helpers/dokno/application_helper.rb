module Dokno
  module ApplicationHelper
    def dokno_article_link(link_text = nil, slug: nil)
      return "Dokno article slug is required" unless slug.present?

      # Check for slug, including deprecated slugs
      article = Article.find_by(slug: slug.strip)
      article = ArticleSlug.find_by(slug: slug.strip)&.article if article.blank?

      return "Dokno article slug '#{slug}' not found" if article.blank?

      %Q(<a class="dokno-link" href="javascript:;" onclick="doknoOpenPanel('#{j article.slug}');">#{link_text.presence || article.title}</a>).html_safe
    end
  end
end
