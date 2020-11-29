# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_28_172631) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dokno_articles", force: :cascade do |t|
    t.string "slug"
    t.string "title"
    t.text "markdown"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "summary"
    t.boolean "active", default: true
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_dokno_categories_on_category_id"
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

  add_foreign_key "dokno_articles_categories", "dokno_articles", column: "article_id"
  add_foreign_key "dokno_articles_categories", "dokno_categories", column: "category_id"
  add_foreign_key "dokno_categories", "dokno_categories", column: "category_id"
  add_foreign_key "dokno_logs", "dokno_articles", column: "article_id"
end
