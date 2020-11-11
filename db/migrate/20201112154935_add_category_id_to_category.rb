class AddCategoryIdToCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :dokno_categories, :category_id, :bigint
    add_index :dokno_categories, :category_id
  end
end
