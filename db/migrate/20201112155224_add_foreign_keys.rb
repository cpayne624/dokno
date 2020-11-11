class AddForeignKeys < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :dokno_categories, :dokno_categories, column: :category_id, primary_key: :id
    add_foreign_key :dokno_articles_categories, :dokno_articles, column: :article_id, primary_key: :id
    add_foreign_key :dokno_articles_categories, :dokno_categories, column: :category_id, primary_key: :id
  end
end
