class AddReviewDueAtToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :dokno_articles, :review_due_at, :datetime
    add_index :dokno_articles, :review_due_at
  end
end
