DatabaseCleaner.allow_remote_database_url = true
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
# #{Faker::Company.catch_phrase}
#{Faker::Markdown.emphasis} #{Faker::Markdown.emphasis}

## #{Faker::Company.catch_phrase}
#{Faker::Lorem.paragraph(sentence_count: 20, random_sentences_to_add: 50)}

### #{Faker::Company.catch_phrase}
#{Faker::Lorem.paragraph(sentence_count: 20, random_sentences_to_add: 50)}
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
        slug:          Faker::Lorem.characters(number: 12),
        title:         Faker::Company.catch_phrase,
        summary:       Faker::Lorem.paragraph(sentence_count: 5, random_sentences_to_add: 10),
        markdown:      faker_markdown,
        review_due_at: Date.today + (rand(-30..365)).days
      )
      show_progress
    end
  end

  show_step 'Uncategorized articles'
  15.times do
    Article.create(
      slug:          Faker::Lorem.characters(number: 12),
      title:         Faker::Company.catch_phrase,
      summary:       Faker::Lorem.paragraph(sentence_count: 5, random_sentences_to_add: 10),
      markdown:      faker_markdown,
      review_due_at: Date.today + (rand(-30..365)).days
    )
    show_progress
  end

  show_step 'Starred articles'
  Article.where(id: Article.all.pluck(:id).shuffle.first(15)).update_all(starred: true)

  show_done
end
