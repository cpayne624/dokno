class AddActiveToArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :dokno_articles, :active, :boolean, default: true
  end
end
