class AddViewsToDoknoArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :dokno_articles, :views, :bigint, default: 0
    add_column :dokno_articles, :last_viewed_at, :datetime
  end
end
