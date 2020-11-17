# Dokno
Dokno (dough-no) is a lightweight Rails Engine for storing and managing your app's <b>DO</b>main <b>KNO</b>wledge.

Dokno is also a play on words, i.e., "I need to look that up 'cause I do' kno'." :eyes:

## Usage
All knowledgebase articles:
```ruby
Dokno::Article.all
```

All knowledgebase categories:
```ruby
Dokno::Category.all
```

All articles within a category:
```ruby
Dokno::Category.take.articles
```

All categories that an article is in:
```ruby
Dokno::Article.take.categories
```

## Installation
Add this line to your application's Gemfile:
```ruby
gem 'dokno'
```

And then execute:
```bash
$ bundle
```

Run Dokno migrations:
```bash
$ rake db:migrate
```

Mount Dokno in your application's routes.rb:
```ruby
mount Dokno::Engine, at: "/dokno"
```

Add the Dokno initializer:
```bash
$ rails g dokno:install
```

Include the Dokno article panel markup, CSS, and JS to the bottom of your application's app/views/layouts/application.html.erb,
just above the closing `</body>`:
```erb
<%= render 'dokno/article_panel' %>
```

## Testing
From `/spec/dummy`:
```bash
$ bundle exec rspec
```

## Contributing
Bug reports and pull requests are welcome at [https://github.com/cpayne624/dokno](https://github.com/cpayne624/dokno).

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
