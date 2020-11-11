$:.push File.expand_path("lib", __dir__)

require "dokno/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "dokno"
  spec.version     = Dokno::VERSION
  spec.authors     = ["Courtney Payne"]
  spec.email       = ["cpayne624@gmail.com"]
  spec.homepage    = "TODO"
  spec.summary     = "TODO: Summary of Dokno."
  spec.description = "TODO: Description of Dokno."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0.3", ">= 6.0.3.4"

  spec.add_development_dependency "pg"
end
