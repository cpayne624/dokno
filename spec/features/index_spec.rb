describe 'category index page', js: true do
  it 'allows article browsing and searching' do
    # Empty site, landing page
    visit dokno_path

    expect(page).to have_content('Add your first category')
    expect(page).not_to have_selector('#category')
    expect(page).not_to have_selector('#search_term')

    # Index page with data, no category selected
    articles = [
      Dokno::Article.create!(slug: 'test1', title: 'Test Article 1', summary: 'Test summary 1'),
      Dokno::Article.create!(slug: 'test2', title: 'Test Article 2', summary: 'Test summary 2')
    ]

    category = Dokno::Category.create!(name: 'Test Category')
    articles.last.categories << category

    visit dokno_path

    expect(page).to have_selector('#category')
    expect(page).to have_selector('#search_term')
    expect(page).to have_content(articles.first.title)
    expect(page).not_to have_content(articles.last.title)

    # Category index page
    within('#dokno-content-container') do
      select(category.name, from: 'category').select_option
    end

    expect(page).to have_content(category.breadcrumb)
    expect(page).to have_content(articles.last.title)
    expect(page).not_to have_content(articles.first.title)

    # Search within a category
    within('#dokno-content-container') do
      fill_in 'search_term', with: 'test'
    end

    expect(page).to have_content('1 article')
    expect(page).to have_content('in this category')
    expect(page).to have_content(articles.last.title)
    expect(page).not_to have_content(articles.first.title)

    # Global search, not scoped to a category
    within('#dokno-content-container') do
      select('Uncategorized', from: 'category').select_option
    end

    expect(page).to have_content('2 articles')
    expect(page).to have_content(articles.first.title)
    expect(page).to have_content(articles.last.title)
    expect(page).not_to have_content('in this category')

    # Sorted alphabetically
    find('#dokno-order-link-alpha').click

    articles_on_page = all('a.dokno-article-title')

    expect(articles_on_page.length).to eq 2
    expect(articles_on_page.first.text).to eq articles.first.title
    expect(articles_on_page.last.text).to eq articles.last.title

    # Sorted by views
    articles.last.update!(views: 100)

    find('#dokno-order-link-views').click

    articles_on_page = all('a.dokno-article-title')

    expect(articles_on_page.first.text).to eq articles.last.title
    expect(articles_on_page.last.text).to eq articles.first.title

    # Sorted by last updated
    find('#dokno-order-link-updated').click

    articles_on_page = all('a.dokno-article-title')

    expect(articles_on_page.first.text).to eq articles.last.title
    expect(articles_on_page.last.text).to eq articles.first.title

    articles.first.update!(title: articles.first.title + 'changed')

    # Sort by last updated, after update
    find('#dokno-order-link-updated').click

    articles_on_page = all('a.dokno-article-title')

    expect(articles_on_page.first.text).to eq articles.first.title
    expect(articles_on_page.last.text).to eq articles.last.title
  end
end
