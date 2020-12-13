class AddStarredToArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :dokno_articles, :starred, :boolean, default: false
  end
end
