module Dokno
  describe Article, type: :model do
    let(:article) { Article.new }
    let(:valid_article) { Article.new(slug: 'slug', title: 'Test Title', summary: 'Test Summary', markdown: 'Test Markdown') }

    context 'validation' do
      it 'requires a slug and a title' do
        expect(article.validate).to be false
        expect(article.errors[:slug]).to include 'can\'t be blank'
        expect(article.errors[:title]).to include 'can\'t be blank'
        expect(Article.new(slug: 'dummy', title: 'dummy').valid?).to be true
      end

      it 'must have a unique slug' do
        articles = [Article.create(slug: 'dummy', title: 'dummy'), Article.create(slug: 'dummy2', title: 'dummy 2')]
        articles.first.slug = articles.last.slug

        expect(articles.first.validate).to be false
        expect(articles.first.errors[:slug]).to include "must be unique, #{articles.last.slug} has already been used"

        articles.first.slug = 'dummy3'
        expect(articles.first.validate).to be true
      end
    end

    context 'instance methods' do
      describe '#markdown' do
        it 'returns the markdown value or an empty string if nil' do
          expected_string = 'dummy'
          article.markdown = expected_string

          expect(article.markdown).to eq expected_string

          article.markdown = nil

          expect(article.markdown).to eq ''
        end
      end

      describe '#markdown_parsed' do
        it 'returns the markdown value markdown processed into HTML markup' do
          expected_string = 'this is **bold**'
          article.markdown = expected_string

          expect(article.markdown_parsed).to eq "<p>this is <strong>bold</strong></p>\n"
        end
      end

      describe '#category_name_list' do
        it 'returns a string representation of the article category names' do
          categories               = [Category.create(name: 'dummy 1'), Category.create(name: 'dummy 2')]
          valid_article.categories = categories
          valid_article.save

          expect(valid_article.category_name_list).to include 'dummy 1'
          expect(valid_article.category_name_list).to include 'dummy 2'
        end
      end

      describe '#host_panel_hash' do
        it 'returns a hash of the article attributes' do
          category = Category.create(name: 'dummy 1')
          valid_article.save
          valid_article.categories << category
          hash = valid_article.host_panel_hash

          # Fully populated article
          expect(hash[:id]).to eq valid_article.id
          expect(hash[:slug]).to eq valid_article.slug
          expect(hash[:title]).to include valid_article.title
          expect(hash[:summary]).to eq valid_article.summary
          expect(hash[:markdown]).to include valid_article.markdown
          expect(hash[:footer]).to include valid_article.slug
          expect(hash[:footer]).to include category.name
          expect(hash[:title]).not_to include 'This article is no longer active'

          # Article without summary, but with markdown
          valid_article.summary = ''
          expect(valid_article.host_panel_hash[:summary]).to be_empty

          # Article missing summary and markdown
          valid_article.markdown = ''
          expect(valid_article.host_panel_hash[:summary]).to eq 'No content'

          # Deactivated article
          valid_article.active = false
          expect(valid_article.host_panel_hash[:title]).to include 'This article is no longer active'
        end
      end

      describe '#permalink' do
        it 'returns the article permalink' do
          expect(valid_article.permalink('dummy_base_path')).to eq 'dummy_base_path/help/articles/slug'
        end
      end

      describe '#log_changes' do
        it 'appropriately logs article data changes' do
          original_attrs = valid_article.attributes
          valid_article.save
          valid_article.update!(
            reset_review_date: true,
            active:            false,
            review_notes:      Faker::Lorem.paragraph,
            slug:              valid_article.slug + 'new',
            title:             valid_article.title + 'new',
            summary:           valid_article.summary + 'new',
            markdown:          valid_article.markdown + 'new'
          )

          expect(valid_article.logs.count).to eq 3
          expect(valid_article.logs.second.meta).to eq "Slug changed from 'slug' to 'slugnew', "\
            "Title changed from 'Test Title' to 'Test Titlenew', Active changed from 'true' to "\
            "'false', Summary was changed, and Markdown was changed"
          expect(valid_article.logs.second.diff_left).to include "<li class=\"del\"><del>"\
            "#{original_attrs['summary']} #{original_attrs['markdown']}</del></li>"
          expect(valid_article.logs.second.diff_right).to include "<li class=\"ins\"><ins>"\
            "#{original_attrs['summary']}<strong>new</strong> #{original_attrs['markdown']}<strong>new</strong></ins></li>"

          expect(valid_article.logs.third.meta).to include "Reviewed for accuracy / relevance. "\
            "Next review date reset to #{valid_article.review_due_at.to_date}."

          expect(valid_article.logs.third.meta).to include valid_article.review_notes
        end
      end

      describe '#reading_time' do
        it 'calculates and returns the approximate reading time for an article' do
          expect(article.reading_time).to be_blank

          # Only returns reading time if > ~1 minute
          article.summary = 'word ' * 10
          expect(article.reading_time).to be_blank

          article.summary = 'word ' * 1_000
          expect(article.reading_time).to eq '~ 5 minutes'

          article.markdown = 'word ' * 1_000
          expect(article.reading_time).to eq '~ 10 minutes'
        end
      end
    end

    context 'class methods' do
      describe '.uncategorized' do
        it 'returns all articles not assigned to a category' do
          valid_article.save

          expect(Article.uncategorized.count).to eq 1
          expect(Article.uncategorized).to include valid_article

          category = Category.create(name: 'dummy 1')
          valid_article.categories << category

          expect(Article.uncategorized.count).to eq 0
        end
      end
    end
  end
end
