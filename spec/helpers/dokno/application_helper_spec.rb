module Dokno
  describe ApplicationHelper, type: :helper do
    describe '#dokno_article_link' do
      it 'generates an in-context article link' do
        article = Article.create!(slug: 'slug', title: 'Test Title', summary: 'Test Summary', markdown: 'Test Markdown')

        # Without link text
        markup = dokno_article_link(slug: article.slug)
        expect(markup).to include "<a class=\"dokno-link\" href=\"javascript:;\" onclick=\"doknoOpenPanel('#{article.slug}');\">#{article.title}</a>"

        # With link text
        markup = dokno_article_link('Test Link Text', slug: article.slug)
        expect(markup).to include "<a class=\"dokno-link\" href=\"javascript:;\" onclick=\"doknoOpenPanel('#{article.slug}');\">Test Link Text</a>"
      end

      it 'shows appropriate message when the slug is not provided' do
        response = dokno_article_link
        expect(response).to include "Dokno article slug is required"
      end

      it 'shows appropriate message when the slug can not be found' do
        response = dokno_article_link(slug: 'bogus')
        expect(response).to include "Dokno article slug 'bogus' not found"
      end
    end
  end
end
