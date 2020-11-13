class CreateArticlesAndCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :dokno_articles_categories, id: false do |t|
      t.belongs_to :article
      t.belongs_to :category
    end

    add_index :dokno_articles_categories, [:article_id, :category_id], unique: true
  end
end
