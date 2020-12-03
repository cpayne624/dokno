class CreateDoknoArticleSlugs < ActiveRecord::Migration[6.0]
  def change
    create_table :dokno_article_slugs do |t|
      t.string :slug, null: false
      t.bigint :article_id

      t.timestamps
    end

    add_index :dokno_article_slugs, :slug, unique: true
    add_index :dokno_article_slugs, :article_id
    add_foreign_key :dokno_article_slugs, :dokno_articles, column: :article_id, primary_key: :id
  end
end
