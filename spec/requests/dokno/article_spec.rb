module Dokno
  describe 'Articles', type: :request do
    let!(:article) { Article.create!(slug: 'slug', title: 'Test Title', summary: 'Test Summary', markdown: 'Test Markdown') }

    describe '#show' do
      it 'returns an article show page' do
        get dokno.article_path(article)

        # Testing that accessing the article via ID redirects to the article permalink via its slug
        expect(response).to redirect_to(dokno.article_path(article.slug))

        follow_redirect!

        expect(response.body).to include article.slug
        expect(response.body).to include article.title
        expect(response.body).to include article.summary
        expect(response.body).to include article.markdown_parsed
      end
    end

    describe '#new' do
      it 'returns the new article form' do
        get dokno.new_article_path

        expect(response.code).to eq '200'
        expect(response.body).to include "New Article"
        expect(response.body).to include "<form action=\"#{dokno.articles_path}\""
        expect(response.body).to include "<button type=\"submit\""

        %w[slug title summary markdown].each do |field_id|
          expect(response.body).to include "<label for=\"#{field_id}\">"
          expect(response.body).to include "id=\"#{field_id}\""
          expect(response.body).to include "name=\"#{field_id}\""
        end
      end

      it 'presents the article template' do
        template_file = File.read(File.join(Rails.root, 'config', 'dokno_template.md'))

        get dokno.new_article_path

        expect(template_file.present?).to be true
        expect(response.body).to include template_file.split('.').first
      end
    end

    describe '#edit' do
      it 'returns the edit article form' do
        get dokno.edit_article_path(article.slug)

        expect(response.code).to eq '200'
        expect(response.body).to include "Edit Article"
        expect(response.body).to include "<form action=\"#{dokno.article_path(article)}\""
        expect(response.body).to include "<button type=\"submit\""

        %w[slug title summary markdown].each do |field_id|
          expect(response.body).to include "<label for=\"#{field_id}\">"
          expect(response.body).to include "id=\"#{field_id}\""
          expect(response.body).to include "name=\"#{field_id}\""

          expect(response.body).to include article.send(field_id.to_sym)
        end
      end
    end

    describe '#create' do
      it 'creates a new article instance' do
        categories = [Category.create!(name: 'Test Category'), Category.create!(name: 'Test Category 2')]
        attrs = {
          slug:     'testslug',
          title:    'Test Title',
          summary:  'Test Summary',
          markdown: 'Test Markdown'
        }

        expect do
          post dokno.articles_path, params: { category_code: categories.map(&:code) }.merge(attrs)
        end.to change(Article, :count).by(1)

        new_article = Article.find_by(slug: 'testslug')

        expect(new_article.present?).to be true
        expect(new_article.categories.count).to eq 2
        expect(new_article.categories).to include categories.first
        expect(new_article.categories).to include categories.last

        persisted_attrs = new_article.attributes.slice('slug', 'title', 'summary', 'markdown').symbolize_keys
        expect(persisted_attrs).to eq attrs
      end

      it 'does not create an invalid article instance' do
        expect do
          post dokno.articles_path, params: { slug: 'invalidbecausetoolongtopassvalidation' }
        end.to change(Article, :count).by(0)

        expect(response.body).to include "Title can&#39;t be blank"
        expect(response.body).to include "Title is too short (minimum is 5 characters)"
        expect(response.body).to include "Slug is too long (maximum is 20 characters)"
      end
    end

    describe '#update' do
      it 'updates an article instance' do
        categories = [Category.create!(name: 'Test Category'), Category.create!(name: 'Test Category 2')]
        attrs = {
          slug:     article.slug + 'new',
          title:    article.title + 'new',
          summary:  article.summary + 'new',
          markdown: article.markdown + 'new'
        }

        expect do
          patch dokno.article_path(article), params: { category_code: categories.map(&:code) }.merge(attrs)
        end.to change(Article, :count).by(0)

        updated_article = Article.find_by(slug: article.slug + 'new')

        expect(updated_article.present?).to be true
        expect(updated_article.categories.count).to eq 2
        expect(updated_article.categories).to include categories.first
        expect(updated_article.categories).to include categories.last

        persisted_attrs = updated_article.attributes.slice('slug', 'title', 'summary', 'markdown').symbolize_keys
        expect(persisted_attrs).to eq attrs
      end

      it 'does not update an article instance if invalid' do
        expect do
          patch dokno.article_path(article), params: { slug: 'invalidbecausetoolongtopassvalidation' }
        end.to change(Article, :count).by(0)

        expect(response.body).to include "Slug is too long (maximum is 20 characters)"
      end
    end

    describe '#destroy' do
      it 'deletes an article instance' do
        expect do
          delete dokno.article_path(article)
        end.to change(Article, :count).by(-1)
      end
    end

    describe '#panel' do
      it 'returns the article in-context panel hash' do
        get dokno.panel_path(article.slug), xhr: true

        response_hash = JSON.parse(response.body).symbolize_keys

        expect(response.code).to eq '200'
        expect(response_hash[:id]).to eq article.id
        expect(response_hash[:title]).to include article.title
        expect(response_hash[:summary]).to include article.summary
        expect(response_hash[:markdown]).to include article.markdown_parsed
      end
    end

    describe '#preview' do
      it 'parses the provided markdown and returns the resulting markup' do
        post dokno.preview_path, params: { markdown: 'this should be **bold**' }, xhr: true

        response_hash = JSON.parse(response.body).symbolize_keys

        expect(response.code).to eq '200'
        expect(response_hash[:parsed_content]).to include "<p>this should be <strong>bold</strong></p>"
      end
    end

    describe '#status' do
      it 'changes an article instance active status' do
        expect(article.active).to be true

        post dokno.status_path, params: { slug: article.slug, active: false }, xhr: true

        expect(response.code).to eq '200'
        expect(article.reload.active).to be false

        post dokno.status_path, params: { slug: article.slug, active: true }, xhr: true

        expect(response.code).to eq '200'
        expect(article.reload.active).to be true
      end
    end

    describe '#article_log' do
      it 'returns article change log markup' do
        old_title   = article.title
        old_summary = article.summary
        article.update!(title: article.title + 'new', summary: article.summary + 'new')

        post dokno.article_log_path, params: { article_id: article.id }, xhr: true

        expect(response.code).to eq '200'
        expect(response.body).to include "Title changed from &#39;#{old_title}&#39; to &#39;#{article.title}&#39;"
        expect(response.body).to include "Summary was changed"
        expect(response.body).to include "<li class=\"del\"><del>#{old_summary}</del></li>"
        expect(response.body).to include "<li class=\"ins\"><ins>#{old_summary}<strong>new</strong></ins></li>"
      end
    end
  end
end
