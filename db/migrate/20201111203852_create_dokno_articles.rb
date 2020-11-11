class CreateDoknoArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :dokno_articles do |t|
      t.string :slug
      t.string :title
      t.text :markdown

      t.timestamps
    end

    add_index :dokno_articles, :slug, unique: true
  end
end
