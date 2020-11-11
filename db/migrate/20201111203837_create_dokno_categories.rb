class CreateDoknoCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :dokno_categories do |t|
      t.string :name

      t.timestamps
    end

    add_index :dokno_categories, :name, unique: true
  end
end
