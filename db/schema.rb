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

ActiveRecord::Schema.define(version: 2022_09_22_060915) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admins", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "ahoy_messages", id: :serial, force: :cascade do |t|
    t.string "token"
    t.text "to"
    t.integer "user_id"
    t.string "user_type"
    t.string "mailer"
    t.text "subject"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_campaign"
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
    t.string "utm_content"
    t.index ["token"], name: "index_ahoy_messages_on_token"
    t.index ["user_id", "user_type"], name: "index_ahoy_messages_on_user_id_and_user_type"
  end

  create_table "app_configs", force: :cascade do |t|
    t.string "shopify_access_token"
    t.string "shopify_session"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "delivered_emails", id: :serial, force: :cascade do |t|
    t.integer "request_id"
    t.integer "marketing_email_id"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state"
    t.string "exception"
    t.index ["aasm_state"], name: "index_delivered_emails_on_aasm_state"
    t.index ["marketing_email_id"], name: "index_delivered_emails_on_marketing_email_id"
    t.index ["request_id"], name: "index_delivered_emails_on_request_id"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.string "uuid"
    t.integer "user_id"
    t.integer "request_id"
    t.string "source_type"
    t.string "source"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.index ["request_id"], name: "index_events_on_request_id"
    t.index ["starts_at"], name: "index_events_on_starts_at"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "marketing_emails", id: :serial, force: :cascade do |t|
    t.string "state"
    t.integer "days_after_state_change"
    t.string "template_name"
    t.string "from", default: "orders@customtattoodesign.ca"
    t.string "subject_line", default: "Lee Roller Owner / Custom Tattoo Design"
    t.integer "version", default: 1
    t.string "email_type"
    t.text "markdown_content"
    t.index ["days_after_state_change"], name: "index_marketing_emails_on_days_after_state_change"
    t.index ["email_type"], name: "index_marketing_emails_on_email_type"
    t.index ["state"], name: "index_marketing_emails_on_state"
  end

  create_table "products", force: :cascade do |t|
    t.string "title"
    t.string "handle"
  end

  create_table "request_images", id: :serial, force: :cascade do |t|
    t.integer "request_id"
    t.string "carrier_wave_file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_request_images_on_request_id"
  end

  create_table "requests", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.boolean "is_first_time"
    t.string "gender"
    t.boolean "has_color"
    t.boolean "has_cover_up"
    t.string "position"
    t.string "large"
    t.string "notes"
    t.string "sku"
    t.string "deposit_order_id"
    t.string "final_order_id"
    t.string "sub_total"
    t.string "request_id"
    t.string "client_id"
    t.string "ticket_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "_ga"
    t.string "linker_param"
    t.string "handle"
    t.string "variant"
    t.datetime "last_visited_at"
    t.string "deposit_variant"
    t.integer "quoted_by_id"
    t.string "state", default: "fresh"
    t.datetime "state_changed_at"
    t.text "description"
    t.datetime "deposited_at"
    t.integer "contacted_by_id"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.string "attributed_by"
    t.string "streak_box_key"
    t.string "thread_gmail_id"
    t.string "style"
    t.string "size"
    t.integer "tattoo_size_id"
    t.datetime "quoted_at"
    t.string "variant_price"
    t.index ["client_id"], name: "index_requests_on_client_id"
    t.index ["created_at"], name: "index_requests_on_created_at"
    t.index ["deposit_order_id"], name: "index_requests_on_deposit_order_id"
    t.index ["first_name", "last_name"], name: "request_names"
    t.index ["quoted_by_id"], name: "index_requests_on_quoted_by_id"
    t.index ["sku"], name: "index_requests_on_sku"
    t.index ["tattoo_size_id", "quoted_at"], name: "index_requests_on_tattoo_size_id_and_quoted_at"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "sales_totals", id: :serial, force: :cascade do |t|
    t.date "sold_on"
    t.integer "salesperson_id"
    t.decimal "order_total", default: "0.0"
    t.integer "order_count", default: 0
    t.integer "box_count", default: 0
    t.index ["salesperson_id"], name: "index_sales_totals_on_salesperson_id"
    t.index ["sold_on", "salesperson_id"], name: "index_sales_totals_on_sold_on_and_salesperson_id"
    t.index ["sold_on"], name: "index_sales_totals_on_sold_on"
  end

  create_table "salespeople", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "streak_api_key"
    t.string "user_key"
    t.boolean "is_active"
    t.boolean "admin"
    t.index ["email"], name: "index_salespeople_on_email", unique: true
    t.index ["reset_password_token"], name: "index_salespeople_on_reset_password_token", unique: true
  end

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.string "data_type", default: "boolean"
    t.string "value"
    t.index ["name"], name: "index_settings_on_name", unique: true
  end

  create_table "shopify_add_order_actions", force: :cascade do |t|
    t.string "order_id"
    t.string "webhook_id"
    t.integer "salesperson_id"
    t.datetime "created_at"
  end

  create_table "tattoo_sizes", force: :cascade do |t|
    t.string "name", null: false
    t.string "deposit_variant_id"
    t.integer "order"
    t.integer "size"
    t.integer "quote_email_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deposit_variant_id"], name: "index_tattoo_sizes_on_deposit_variant_id"
    t.index ["name"], name: "index_tattoo_sizes_on_name"
    t.index ["order"], name: "index_tattoo_sizes_on_order"
    t.index ["quote_email_id"], name: "index_tattoo_sizes_on_quote_email_id"
    t.index ["size"], name: "index_tattoo_sizes_on_size"
  end

  create_table "transactional_emails", force: :cascade do |t|
    t.string "name"
    t.string "smart_id"
    t.index ["smart_id"], name: "index_transactional_emails_on_smart_id", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.bigint "shopify_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_token", limit: 30
    t.boolean "presales_opt_in", default: true
    t.boolean "marketing_opt_in"
    t.boolean "crm_opt_in", default: true
    t.string "phone_number"
    t.string "timezone"
    t.string "uuid"
    t.string "first_name"
    t.string "last_name"
    t.string "job_status"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["shopify_id"], name: "index_users_on_shopify_id"
  end

  create_table "variants", force: :cascade do |t|
    t.string "product_id"
    t.string "title"
    t.string "price"
    t.string "fulfillment_service"
    t.string "option1"
    t.string "option2"
    t.string "option3"
    t.index ["product_id"], name: "index_variants_on_product_id"
  end

  create_table "webhooks", force: :cascade do |t|
    t.string "source", null: false
    t.string "source_id"
    t.string "email"
    t.string "action_name", null: false
    t.string "params"
    t.string "headers"
    t.string "referrer"
    t.integer "request_id"
    t.string "last_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state"
    t.integer "tries", default: 0
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_webhooks_on_deleted_at"
    t.index ["email"], name: "index_webhooks_on_email"
    t.index ["request_id"], name: "index_webhooks_on_request_id"
    t.index ["source", "action_name"], name: "index_webhooks_on_source_and_action_name"
    t.index ["source", "source_id", "action_name"], name: "index_webhooks_on_source_and_source_id_and_action_name"
    t.index ["source"], name: "index_webhooks_on_source"
    t.index ["source_id"], name: "index_webhooks_on_source_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "delivered_emails", "requests"
  add_foreign_key "events", "users"
  add_foreign_key "request_images", "requests"
  add_foreign_key "requests", "users"
  add_foreign_key "sales_totals", "salespeople"
end
