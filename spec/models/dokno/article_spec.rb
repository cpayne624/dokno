module Dokno
  describe Article do
    context 'validation' do
      it 'requires a slug and a title' do
        article = Article.new

        expect(article.validate).to be false
        expect(article.errors[:slug]).to include 'can\'t be blank'
        expect(article.errors[:title]).to include 'can\'t be blank'
        expect(Article.new(slug: 'dummy', title: 'dummy').valid?).to be true
      end

      it 'must have a unique slug' do
        articles = [Article.create(slug: 'dummy', title: 'dummy'), Article.create(slug: 'dummy2', title: 'dummy 2')]
        articles.first.slug = articles.last.slug

        expect(articles.first.validate).to be false
        expect(articles.first.errors[:slug]).to include "must be unique, #{articles.last.slug} already exists"

        articles.first.slug = 'dummy3'
        expect(articles.first.validate).to be true
      end
    end
  end
end
