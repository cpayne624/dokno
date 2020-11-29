class CreateDoknoLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :dokno_logs do |t|
      t.bigint :article_id
      t.string :username
      t.text :meta
      t.text :diff_left
      t.text :diff_right

      t.timestamps
    end
    add_index :dokno_logs, :article_id
    add_index :dokno_logs, :username

    add_foreign_key :dokno_logs, :dokno_articles, column: :article_id, primary_key: :id
  end
end
