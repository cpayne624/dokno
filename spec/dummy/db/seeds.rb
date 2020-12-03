DatabaseCleaner.clean_with(:truncation)

module Dokno
  SPINNER = Enumerator.new do |e|
    loop do
      e.yield '|'
      e.yield '/'
      e.yield '-'
      e.yield '\\'
    end
  end

  def self.show_step(step); printf " \n#{step} "; end
  def self.show_progress; printf "#{SPINNER.next}\b"; end
  def self.show_done; printf " \nAll done\n\n"; end

  def self.faker_markdown
    %(
#{Faker::Markdown.sandwich(sentences: 15)}

#{Faker::Markdown.unordered_list}

#{Faker::Lorem.paragraphs(number: 20).join("\n")}

#{Faker::Markdown.table}

#{Faker::Lorem.paragraphs(number: 20).join("\n")}
      )
  end

  # Categories

  show_step 'Categories'
  10.times do
    Category.create(name: Faker::Company.industry)
    show_progress
  end

  10.times do
    Category.all.sample.children << Category.new(name: Faker::Company.profession.capitalize)
    show_progress
  end

  10.times do
    Category.where.not(category_id: nil).all.sample.children << Category.new(name: Faker::Company.type)
    show_progress
  end

  # Articles

  show_step 'Categorized articles'
  Category.find_each do |category|
    rand(0..15).times do
      category.articles << Article.new(
        slug:     Faker::Lorem.characters(number: 12),
        title:    Faker::Lorem.sentence,
        summary:  Faker::Lorem.paragraphs.join("\n"),
        markdown: faker_markdown
      )
      show_progress
    end
  end

  show_step 'Uncategorized articles'
  15.times do
    Article.create(
      slug:     Faker::Lorem.characters(number: 12),
      title:    Faker::Lorem.sentence,
      summary:  Faker::Lorem.paragraphs.join("\n"),
      markdown: faker_markdown
    )
    show_progress
  end

  show_done
end
