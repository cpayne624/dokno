$:.push File.expand_path("lib", __dir__)

require "dokno/version"

Gem::Specification.new do |spec|
  spec.name        = "dokno"
  spec.version     = Dokno::VERSION
  spec.authors     = ["Courtney Payne"]
  spec.email       = ["cpayne624@gmail.com"]
  spec.homepage    = "https://github.com/cpayne624/dokno"
  spec.summary     = "Dokno (dough-no) is a lightweight mountable Rails Engine for storing and managing your app's domain knowledge."
  spec.description = "Dokno allows you to easily mount a self-contained knowledgebase / wiki / help system to your Rails app."
  spec.license     = "MIT"
  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/cpayne624/dokno/issues",
    "changelog_uri"   => "https://github.com/cpayne624/dokno/blob/master/CHANGELOG.md"
  }

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "diffy", "~> 3.4"     # Change log diffing
  spec.add_dependency "redcarpet", "~> 3.6" # Markdown to HTML processor

  spec.add_development_dependency "bullet", "~> 7.0"
  spec.add_development_dependency "capybara", "~> 3.38"
  spec.add_development_dependency "database_cleaner-active_record", "~> 2.1"
  spec.add_development_dependency "faker", "~> 3.1"
  spec.add_development_dependency "pg", "~> 1.4"
  spec.add_development_dependency "pry-byebug", "~> 3.10"
  spec.add_development_dependency "puma", "~> 6.1"
  spec.add_development_dependency "rails", '~> 6.1'
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "selenium-webdriver", "~> 4.8"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "webdrivers", "~> 5.2"
end
