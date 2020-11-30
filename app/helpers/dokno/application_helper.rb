module Dokno
  module ApplicationHelper
    def dokno_article_modal(link_text = nil, slug: nil)
      return "Dokno article slug is required"         unless slug.present?
      return "Dokno article slug '#{slug}' not found" unless (article = Dokno::Article.find_by(slug: slug.strip))

      %Q(
        <a href="javascript:;" onclick="doknoOpenPanel('#{j slug}');">#{link_text.presence || article.title}</a>
      ).html_safe
    end
  end
end
