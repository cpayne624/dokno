class AddSummaryToArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :dokno_articles, :summary, :text
  end
end
