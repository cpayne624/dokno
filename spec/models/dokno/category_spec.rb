module Dokno
  describe Category, type: :model do
    let(:category) { Category.new }
    let(:valid_category) { Category.new(name: 'Test Category') }

    context 'validation' do
      it 'requires a name' do
        expect(category.validate).to be false
        expect(category.errors[:name]).to include 'can\'t be blank'
        expect(Category.new(name: 'dummy').valid?).to be true
      end

      it 'must have a unique name' do
        categories = [Category.create(name: 'dummy'), Category.create(name: 'dummy 2')]
        categories.first.name = categories.last.name

        expect(categories.first.validate).to be false
        expect(categories.first.errors[:name]).to include 'has already been taken'

        categories.first.name = 'dummy 3'
        expect(categories.first.validate).to be true
      end

      it 'can not have its parent set to self' do
        categories = [Category.create(name: 'dummy'), Category.create(name: 'dummy 2')]
        categories.first.category_id = categories.first.id

        expect(categories.first.validate).to be false
        expect(categories.first.errors[:category_id]).to include 'can\'t set parent to self'

        categories.first.category_id = categories.last.id
        expect(categories.first.validate).to be true
      end
    end

    context 'instance methods' do
      describe '#breadcrumb' do
        it 'returns the breadcrumb for the nested category' do
          valid_category.save
          parent_category        = Category.create!(name: 'Test Parent Category')
          parent_parent_category = Category.create!(name: 'Test Parent Parent Category')

          parent_category.update!(category_id: parent_parent_category.id)
          valid_category.update!(category_id: parent_category.id)

          breadcrumb = valid_category.breadcrumb

          expect(breadcrumb).to include parent_parent_category.name
          expect(breadcrumb).to include parent_category.name
          expect(breadcrumb).to include valid_category.name
        end
      end

      describe '#articles_in_branch' do
        it 'returns the articles assigned to the category or any children categories' do
          valid_category.save
          child_category  = Category.create!(name: 'Test Child Category')
          article         = Article.create!(slug: 'slug', title: 'Test Title')
          another_article = Article.create!(slug: 'slug2', title: 'Test Title 2')
          child_category.update!(category_id: valid_category.id)

          expect(valid_category.articles_in_branch).to be_empty

          valid_category.articles << article
          child_category.articles << another_article

          expect(valid_category.articles_in_branch.count).to eq 2
          expect(valid_category.articles_in_branch).to include article
          expect(valid_category.articles_in_branch).to include another_article

          expect(child_category.articles_in_branch.count).to eq 1
          expect(child_category.articles_in_branch).to include another_article
        end
      end
    end

    context 'class methods' do
      describe '.select_option_markup' do
        it 'builds and returns the category select option markup' do
          valid_category.save!
          categories = [valid_category, Category.create!(name: 'Test Category 2'), Category.create!(name: 'Test Category 3')]
          selected_category = categories.pop
          excluded_category = categories.sample

          select_option_markup = Category.select_option_markup
          categories.each do |category|
            expect(select_option_markup).to include category.code
            expect(select_option_markup).to include category.name
          end

          select_option_markup = Category.select_option_markup(selected_category_codes: [selected_category.code])
          expect(select_option_markup).to include "<option value=\"#{selected_category.code}\" selected=\"selected\">#{selected_category.name}</option>"
          expect(select_option_markup).to include "\"#{excluded_category.code}\""
        end
      end

      describe '.cache_key' do
        it 'returns the updated_at timestamp of the most-recently updated category or article' do
          article = Article.create!(slug: 'testslug', title: 'Test Title', created_at: 1.day.ago, updated_at: 1.day.ago)
          valid_category.save!

          expected_cache_key = valid_category.updated_at

          expect(Category.cache_key).to eq expected_cache_key

          valid_category.update!(name: valid_category.name + 'changed')

          expect(Category.cache_key).not_to eq expected_cache_key
          expect(Category.cache_key).to eq valid_category.updated_at

          article.update!(title: article.title + 'changed')

          expect(Category.cache_key).not_to eq valid_category.updated_at
          expect(Category.cache_key).to eq article.updated_at
        end
      end
    end
  end
end
