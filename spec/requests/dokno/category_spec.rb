module Dokno
  describe 'Categories', type: :request do
    let!(:category) { Category.create!(name: 'Test Category') }

    describe '#index' do
      it 'returns articles that are up for review' do
        days_out = Dokno.config.article_review_prompt_days
        article_not_up_for_review = Article.create!(slug: 'slug1', title: 'Test Title 1', review_due_at: Date.today + (days_out + 1).days)
        article_up_for_review     = Article.create!(slug: 'slug2', title: 'Test Title 2', review_due_at: Date.today + days_out.days)
        article_past_due          = Article.create!(slug: 'slug3', title: 'Test Title 3', review_due_at: Date.today - 1.day)

        get dokno.up_for_review_path

        expect(response.body).to include article_up_for_review.title
        expect(response.body).to include article_past_due.title
        expect(response.body).not_to include article_not_up_for_review.title
        expect(response.body.squish).to include "2 articles up for review"
        expect(response.body).to include "This article was up for an accuracy / relevance review 1 days ago"
        expect(response.body).to include "This article is up for an accuracy / relevance review in #{days_out} days"
      end

      it 'returns search results (all articles)' do
        article = Article.create!(slug: 'slug', title: 'Test Title', summary: 'Test Summary banana', markdown: 'Test Markdown')

        get "#{dokno.root_path}?search_term=#{CGI.escape('summary banana')}"

        expect(response.code).to eq '200'
        expect(response.body).to include "1 article"
        expect(response.body).to include "found containing the search term"
        expect(response.body).to include "<span class=\"font-serif\">&ldquo;</span> summary banana <span class=\"font-serif\">&rdquo;</span>"
        expect(response.body).to include article.title
        expect(response.body).to include article.summary

        get "#{dokno.root_path}?search_term=#{CGI.escape('string that is not there')}"

        expect(response.code).to eq '200'
        expect(response.body).to include "No articles"
        expect(response.body).to include "found containing the search term"
        expect(response.body).to include "<span class=\"font-serif\">&ldquo;</span> string that is not there <span class=\"font-serif\">&rdquo;</span>"
        expect(response.body).to include "No articles found"

        # Should return categorized articles as well
        article.categories << category

        get "#{dokno.root_path}?search_term=#{CGI.escape('summary banana')}"

        expect(response.body).to include "1 article"
        expect(response.body).to include "found containing the search term"
        expect(response.body).to include article.title
        expect(response.body).to include article.summary
      end

      it 'returns search results (category scoped)' do
        another_category = Category.create!(name: 'Another Category')
        article = Article.create!(slug: 'slug', title: 'Test Title', summary: 'Test Summary banana', markdown: 'Test Markdown')
        article.categories << category

        get "#{dokno.article_index_path(another_category.code)}?search_term=#{CGI.escape('summary banana')}"

        expect(response.code).to eq '200'
        expect(response.body).to include "No articles"
        expect(response.body).to include "found containing the search term"
        expect(response.body).to include "<span class=\"font-serif\">&ldquo;</span> summary banana <span class=\"font-serif\">&rdquo;</span>"
        expect(response.body).to include "No articles found in this category matching the given search criteria"

        get "#{dokno.article_index_path(category.code)}?search_term=#{CGI.escape('summary banana')}"

        expect(response.body).to include "1 article"
        expect(response.body).to include "found containing the search term"
        expect(response.body).to include "<span class=\"font-serif\">&ldquo;</span> summary banana <span class=\"font-serif\">&rdquo;</span>"
        expect(response.body).to include article.title
        expect(response.body).to include article.summary
      end

      it 'returns the landing page (including uncategorized articles)' do
        article = Article.create!(slug: 'slug', title: 'Test Title', summary: 'Test Summary', markdown: 'Test Markdown')

        get dokno.root_path

        expect(response.code).to eq '200'
        expect(response.body).to include "name=\"category\" id=\"category\""
        expect(response.body).to include "name=\"search_term\" id=\"search_term\""
        expect(response.body).to include category.code
        expect(response.body).to include category.name

        # Includes uncategorized article
        expect(response.body).to include article.title
        expect(response.body).to include article.summary
      end

      it 'returns a category index page' do
        article = Article.create!(slug: 'slug', title: 'Test Title', summary: 'Test Summary', markdown: 'Test Markdown')

        get "#{dokno.article_index_path(category.code)}?"

        expect(response.code).to eq '200'
        expect(response.body).to include "name=\"category\" id=\"category\""
        expect(response.body).to include "name=\"search_term\" id=\"search_term\""
        expect(response.body).to include category.code
        expect(response.body).to include category.name

        # Does not include the categorized article
        expect(response.body).not_to include article.title
        expect(response.body).not_to include article.summary

        article.categories << category

        get "#{dokno.article_index_path(category.code)}?"

        # Now includes the categorized article
        expect(response.body).to include article.title
        expect(response.body).to include article.summary
      end
    end

    describe '#new' do
      it 'returns the new category form' do
        get dokno.new_category_path

        expect(response.code).to eq '200'
        expect(response.body).to include "New Category"
        expect(response.body).to include "<form action=\"#{dokno.categories_path}\""
        expect(response.body).to include "<button type=\"submit\""

        %w[name parent_category_code].each do |field_id|
          expect(response.body).to include "<label for=\"#{field_id}\">"
          expect(response.body).to include "id=\"#{field_id}\""
          expect(response.body).to include "name=\"#{field_id}\""
        end
      end
    end

    describe '#edit' do
      it 'returns the edit category form' do
        parent_category = Category.create!(name: 'Test Parent Category')
        category.update!(category_id: parent_category.id)

        get dokno.edit_category_path(category)

        expect(response.code).to eq '200'
        expect(response.body).to include "Edit Category"
        expect(response.body).to include "<form action=\"#{dokno.category_path(category)}\""
        expect(response.body).to include "<button type=\"submit\""

        %w[name parent_category_code].each do |field_id|
          expect(response.body).to include "<label for=\"#{field_id}\">"
          expect(response.body).to include "id=\"#{field_id}\""
          expect(response.body).to include "name=\"#{field_id}\""
        end

        expect(response.body).to include category.name
      end
    end

    describe '#create' do
      it 'creates a new category instance' do
        parent_category = Category.create!(name: 'Test Parent Category')

        expect do
          post dokno.categories_path, params: { name: 'Created Category', parent_category_code: parent_category.code }
        end.to change(Category, :count).by(1)

        follow_redirect!
        expect(response.body).to include 'Category was created'

        new_category = Category.find_by(name: 'Created Category')

        expect(new_category.present?).to be true
        expect(new_category.parent).to eq parent_category
      end

      it 'does not create an invalid category instance' do
        expect do
          post dokno.categories_path, params: { name: '' }
        end.to change(Category, :count).by(0)

        expect(response.body).to include "Name can&#39;t be blank"
      end
    end

    describe '#update' do
      it 'updates a category instance' do
        parent_category = Category.create!(name: 'Test Parent Category')

        expect do
          patch dokno.category_path(category), params: { name: category.name + 'new', parent_category_code: parent_category.code }
        end.to change(Category, :count).by(0)

        follow_redirect!
        expect(response.body).to include 'Category was updated'

        updated_category = Category.find_by(name: category.name + 'new')

        expect(updated_category.present?).to be true
        expect(updated_category.parent).to eq parent_category
      end

      it 'does not update a category instance if invalid' do
        expect do
          patch dokno.category_path(category), params: { name: '' }
        end.to change(Category, :count).by(0)

        expect(response.body).to include "Name can&#39;t be blank"
      end
    end

    describe '#destroy' do
      it 'deletes a category instance' do
        expect do
          delete dokno.category_path(category)
        end.to change(Category, :count).by(-1)
      end
    end
  end
end
