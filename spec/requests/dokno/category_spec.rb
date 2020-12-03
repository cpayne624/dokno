module Dokno
  describe 'Categories', type: :request do
    let!(:category) { Category.create!(name: 'Test Category') }

    describe '#index' do
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

        get "#{dokno.root_path}?id=#{another_category.id}&search_term=#{CGI.escape('summary banana')}"

        expect(response.code).to eq '200'
        expect(response.body).to include "No articles"
        expect(response.body).to include "found containing the search term"
        expect(response.body).to include "<span class=\"font-serif\">&ldquo;</span> summary banana <span class=\"font-serif\">&rdquo;</span>"
        expect(response.body).to include "No articles found in this category matching the given search criteria"

        get "#{dokno.root_path}?id=#{category.id}&search_term=#{CGI.escape('summary banana')}"

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
        expect(response.body).to include category.id.to_s
        expect(response.body).to include category.name

        # Includes uncategorized article
        expect(response.body).to include article.title
        expect(response.body).to include article.summary
      end

      it 'returns a category index page' do
        article = Article.create!(slug: 'slug', title: 'Test Title', summary: 'Test Summary', markdown: 'Test Markdown')

        get "#{dokno.root_path}?id=#{category.id}"

        expect(response.code).to eq '200'
        expect(response.body).to include "name=\"category\" id=\"category\""
        expect(response.body).to include "name=\"search_term\" id=\"search_term\""
        expect(response.body).to include category.id.to_s
        expect(response.body).to include category.name
        expect(response.body).to include "<option value=\"#{category.code}\" selected=\"selected\">#{category.name}</option>"

        # Does not include the categorized article
        expect(response.body).not_to include article.title
        expect(response.body).not_to include article.summary

        article.categories << category

        get "#{dokno.root_path}?id=#{category.id}"

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
        expect(response.body).to include "<option value=\"#{parent_category.code}\" selected=\"selected\">#{parent_category.name}</option>"
      end
    end

    describe '#create' do
      it 'creates a new category instance' do
        parent_category = Category.create!(name: 'Test Parent Category')

        expect do
          post dokno.categories_path, params: { name: 'Created Category', parent_category_code: parent_category.code }
        end.to change(Category, :count).by(1)

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
  end
end
