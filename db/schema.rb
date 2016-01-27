# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160125220020) do

  create_table "product_groups", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_variants", force: :cascade do |t|
    t.integer  "product_id"
    t.string   "shopify_id"
    t.boolean  "has_color"
    t.boolean  "has_cover_up"
    t.float    "price"
    t.string   "sku"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "product_variants", ["product_id", "has_color", "has_cover_up"], name: "product_color_cover"
  add_index "product_variants", ["product_id"], name: "index_product_variants_on_product_id"
  add_index "product_variants", ["sku"], name: "index_product_variants_on_sku"

  create_table "products", force: :cascade do |t|
    t.integer  "product_group_id"
    t.string   "name"
    t.string   "product_type"
    t.string   "handle"
    t.boolean  "is_deposit",       null: false
    t.boolean  "is_final_payment", null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "products", ["is_deposit"], name: "index_products_on_is_deposit"
  add_index "products", ["is_final_payment"], name: "index_products_on_is_final_payment"
  add_index "products", ["product_group_id"], name: "index_products_on_product_group_id"
  add_index "products", ["product_type"], name: "index_products_on_product_type"

  create_table "requests", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token"
    t.boolean  "is_first_time"
    t.string   "gender"
    t.boolean  "has_color"
    t.boolean  "has_cover_up"
    t.string   "position"
    t.string   "large"
    t.string   "notes"
    t.string   "qid"
    t.string   "requesting_cid"
    t.string   "ticket_url"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "requests", ["user_id"], name: "index_requests_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "first_name",             default: ""
    t.string   "last_name",              default: ""
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
