# Dokno
![CI RSpec](https://github.com/cpayne624/dokno/workflows/CI%20RSpec/badge.svg)

Dokno (dough-no) is a lightweight Rails Engine for storing and managing your app's <b>Do</b>main <b>Kno</b>wledge.
Dokno is also a play on words, such as, "I need to look that up because I do' kno'." ¯\_(ツ)_/¯

Dokno allows you to easily mount a complete, yet simple, self-contained knowledgebase site
to your Rails app where you or your users can author articles relevant to your app.

Dokno supports article categorization and naive article searching for discovery,
as well as a view helper for providing inline, in-context access to articles to your users.

    <%= dokno_article_modal({link-text}, slug: {unique-article-slug}) %>

## Screenshots

### Knowledgebase Landing Page
![Landing Page](./README/landing_page.png)

### Knowledgebase Article
![Article](./README/article.png)

### Editing An Article
![Editing An Article](./README/article_edit.png)

### In-Context Flyout Article
![Host App Page](./README/host_app_flyout.png)

## Dependencies
Dokno is purposefully lightweight and fast, with only two dependencies, the excellent
[redcarpet](https://github.com/vmg/redcarpet) (Markdown processing) &
[diffy](https://github.com/samg/diffy) (change log diffing) gems,
each of which have no further dependencies.

It is expected that Dokno is mounted to a Rails app using a database via ActiveRecord.

## Installation
Add this line to your application's Gemfile:
```ruby
gem 'dokno'
```

And then run:
```bash
$ bundle
```

Run Dokno migrations:
```bash
$ rake db:migrate
```

Mount Dokno in your application's `routes.rb` at the desired path:
```ruby
mount Dokno::Engine, at: "/help"
```

To add `config/initializers/dokno.rb`, run:
```bash
$ rails g dokno:install
```

Include the Dokno in-context flyout article panel markup, CSS, and JS to the bottom of your application's
`app/views/layouts/application.html.erb`, just above the closing `</body>`:
```erb
<%= render 'dokno/article_panel' %>
```

## Usage

### Knowledgebase Site
The Dokno knowledgebase is mounted to the path you specify in your `routes.rb` above. You can use the `dokno_path` route helper
to link your users to the knowledgebase site.

    <a target="_blank" href="<%= dokno_path %>">Dokno Knowledgebase</a>

### In-Context Article Links
Each article has a unique 'slug' or token that is used to access articles inline from your app. Use the `dokno_article_modal`
view helper to add links in your app to relevant articles. Clicking an in-context link fetches the target article
asynchronously and displays it to the user via a flyout panel overlay in your app.

    <%= dokno_article_modal({link-text}, slug: {unique-article-slug}) %>

### Accessing Dokno Data Directly
You typically won't ever need to interact with Dokno data directly. However, Dokno data is stored within your database
and is accessible via ActiveRecord as any other model. Dokno data is `Dokno::` namespaced.

You may access Dokno article and category data directly via:

```ruby
Dokno::Category.take
=> #<Dokno::Category id: 1, name: "Category Name", ... >

Dokno::Article.all
=> #<ActiveRecord::Relation [#<Dokno::Article id: 1, slug: "uniqueslug", ... >, ...]
Dokno::Category.take.articles
=> #<ActiveRecord::Relation [#<Dokno::Article id: 1, slug: "uniqueslug", ... >, ...]

Dokno::Category.all
=> #<ActiveRecord::Relation [#<Dokno::Category id: 1, name: "Category Name", ... >, ...]
Dokno::Article.take.categories
=> #<ActiveRecord::Relation [#<Dokno::Category id: 1, name: "Category Name", ... >, ...]

Dokno::Category.take.parent
=> #<Dokno::Category id: 2, name: "Parent Category Name", category_id: 1, ... >
Dokno::Category.take.children
=> #<ActiveRecord::Relation [#<Dokno::Category id: 3, name: "Child Category Name", ... >, ...]
```

## Contributing
Contributions are welcome. Prior to submitting a PR, make sure that all existing specs pass and any new functionality added
is covered by passing specs.

To run tests, from the root directory run:
```bash
$ bundle exec rspec
```

## Credits
- [redcarpet](https://github.com/vmg/redcarpet)
- [diffy](https://github.com/samg/diffy)
- [Feather Icons](https://github.com/feathericons/feather)

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
