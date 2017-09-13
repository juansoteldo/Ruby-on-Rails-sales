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

ActiveRecord::Schema.define(version: 20170912190308) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "ahoy_messages", force: :cascade do |t|
    t.string   "token"
    t.text     "to"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "mailer"
    t.text     "subject"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_campaign"
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
    t.string   "utm_content"
  end

  add_index "ahoy_messages", ["token"], name: "index_ahoy_messages_on_token", using: :btree
  add_index "ahoy_messages", ["user_id", "user_type"], name: "index_ahoy_messages_on_user_id_and_user_type", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "delivered_emails", force: :cascade do |t|
    t.integer  "request_id"
    t.integer  "marketing_email_id"
    t.datetime "sent_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "delivered_emails", ["marketing_email_id"], name: "index_delivered_emails_on_marketing_email_id", using: :btree
  add_index "delivered_emails", ["request_id"], name: "index_delivered_emails_on_request_id", using: :btree

  create_table "marketing_emails", force: :cascade do |t|
    t.string  "state"
    t.integer "days_after_state_change"
    t.string  "template_name"
    t.string  "from",                    default: "orders@customtattoodesign.ca"
    t.string  "template_path",           default: "box_mailer"
    t.string  "subject_line",            default: "Lee Roller Owner / Custom Tattoo Design"
    t.integer "version",                 default: 1
  end

  add_index "marketing_emails", ["days_after_state_change"], name: "index_marketing_emails_on_days_after_state_change", using: :btree
  add_index "marketing_emails", ["state"], name: "index_marketing_emails_on_state", using: :btree

  create_table "request_images", force: :cascade do |t|
    t.integer  "request_id"
    t.string   "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "request_images", ["request_id"], name: "index_request_images_on_request_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "first_name",       default: ""
    t.string   "last_name",        default: ""
    t.string   "token"
    t.boolean  "is_first_time"
    t.string   "gender"
    t.boolean  "has_color"
    t.boolean  "has_cover_up"
    t.string   "position"
    t.string   "large"
    t.string   "notes"
    t.string   "sku"
    t.string   "deposit_order_id"
    t.string   "final_order_id"
    t.string   "sub_total"
    t.string   "request_id"
    t.string   "client_id"
    t.string   "ticket_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "_ga"
    t.string   "linker_param"
    t.string   "handle"
    t.string   "variant"
    t.datetime "last_visited_at"
    t.string   "deposit_variant"
    t.integer  "quoted_by_id"
    t.string   "state",            default: "fresh"
    t.datetime "state_changed_at"
    t.text     "description"
    t.datetime "deposited_at"
    t.integer  "contacted_by_id"
  end

  add_index "requests", ["client_id"], name: "index_requests_on_client_id", using: :btree
  add_index "requests", ["created_at"], name: "index_requests_on_created_at", using: :btree
  add_index "requests", ["deposit_order_id"], name: "index_requests_on_deposit_order_id", using: :btree
  add_index "requests", ["quoted_by_id"], name: "index_requests_on_quoted_by_id", using: :btree
  add_index "requests", ["sku"], name: "index_requests_on_sku", using: :btree
  add_index "requests", ["user_id"], name: "index_requests_on_user_id", using: :btree

  create_table "sales_totals", force: :cascade do |t|
    t.date    "sold_on"
    t.integer "salesperson_id"
    t.decimal "order_total",    default: 0.0
    t.integer "order_count",    default: 0
    t.integer "box_count",      default: 0
  end

  add_index "sales_totals", ["salesperson_id"], name: "index_sales_totals_on_salesperson_id", using: :btree
  add_index "sales_totals", ["sold_on", "salesperson_id"], name: "index_sales_totals_on_sold_on_and_salesperson_id", using: :btree
  add_index "sales_totals", ["sold_on"], name: "index_sales_totals_on_sold_on", using: :btree

  create_table "salespeople", force: :cascade do |t|
    t.string   "email",                    default: "", null: false
    t.string   "encrypted_password",       default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",            default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "encrypted_streak_api_key"
    t.string   "user_key"
    t.boolean  "is_active"
    t.boolean  "admin"
  end

  add_index "salespeople", ["email"], name: "index_salespeople_on_email", unique: true, using: :btree
  add_index "salespeople", ["reset_password_token"], name: "index_salespeople_on_reset_password_token", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "shopify_id",             limit: 8
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "opted_out",                         default: false
    t.string   "authentication_token",   limit: 30
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["shopify_id"], name: "index_users_on_shopify_id", using: :btree

  add_foreign_key "delivered_emails", "requests"
  add_foreign_key "request_images", "requests"
  add_foreign_key "requests", "users"
  add_foreign_key "sales_totals", "salespeople"
end
