class Baseline < ActiveRecord::Migration[6.0]
  def change
    create_table "dokno_article_slugs", force: :cascade do |t|
      t.string "slug", null: false
      t.bigint "article_id"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["article_id"], name: "index_dokno_article_slugs_on_article_id"
      t.index ["slug"], name: "index_dokno_article_slugs_on_slug", unique: true
    end

    create_table "dokno_articles", force: :cascade do |t|
      t.string "slug"
      t.string "title"
      t.text "markdown"
      t.text "summary"
      t.boolean "active", default: true
      t.bigint "views", default: 0
      t.datetime "last_viewed_at"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["slug"], name: "index_dokno_articles_on_slug", unique: true
    end

    create_table "dokno_articles_categories", id: false, force: :cascade do |t|
      t.bigint "article_id"
      t.bigint "category_id"
      t.index ["article_id", "category_id"], name: "index_dokno_articles_categories_on_article_id_and_category_id", unique: true
      t.index ["article_id"], name: "index_dokno_articles_categories_on_article_id"
      t.index ["category_id"], name: "index_dokno_articles_categories_on_category_id"
    end

    create_table "dokno_categories", force: :cascade do |t|
      t.string "name"
      t.bigint "category_id"
      t.string "code", null: false
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["category_id"], name: "index_dokno_categories_on_category_id"
      t.index ["code"], name: "index_dokno_categories_on_code", unique: true
      t.index ["name"], name: "index_dokno_categories_on_name", unique: true
    end

    create_table "dokno_logs", force: :cascade do |t|
      t.bigint "article_id"
      t.string "username"
      t.text "meta"
      t.text "diff_left"
      t.text "diff_right"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
      t.index ["article_id"], name: "index_dokno_logs_on_article_id"
      t.index ["username"], name: "index_dokno_logs_on_username"
    end

    add_foreign_key "dokno_article_slugs", "dokno_articles", column: "article_id"
    add_foreign_key "dokno_articles_categories", "dokno_articles", column: "article_id"
    add_foreign_key "dokno_articles_categories", "dokno_categories", column: "category_id"
    add_foreign_key "dokno_categories", "dokno_categories", column: "category_id"
    add_foreign_key "dokno_logs", "dokno_articles", column: "article_id"
  end
end
