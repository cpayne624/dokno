class AddCodeToCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :dokno_categories, :code, :string, null: false
    add_index :dokno_categories, :code, unique: true
  end
end
