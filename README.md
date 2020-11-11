# Dokno
Dokno (prounounced dough-no) is a lightweight Rails Engine for storing and managing your app's <b>DO</b>main <b>KNO</b>wledge.

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

Import database migrations:
```bash
$ rake dokno:install:migrations
```

Run migrations:
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

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
