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

ActiveRecord::Schema.define(version: 2018_05_10_043414) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "association_informations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "membership_type"
    t.string "membership_id"
    t.string "raking"
    t.string "affiliation"
    t.string "certification"
    t.string "company"
  end

  create_table "billing_addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "postal_code"
    t.string "city"
    t.string "state"
  end

  create_table "contact_informations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "country_code_phone"
    t.integer "cell_phone"
    t.string "alternative_email"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "postal_code"
    t.string "state"
    t.string "city"
    t.integer "work_phone"
    t.string "emergency_contact_full_name"
    t.string "emergency_contact_country_code_phone"
    t.integer "emergency_contact_phone"
  end

  create_table "event_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_event_types_on_deleted_at"
  end

  create_table "medical_informations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "insurance_provider"
    t.string "insurance_policy_number"
    t.string "group_id"
    t.string "primary_physician_full_name"
    t.string "primary_physician_country_code_phone"
    t.integer "primary_physician_phone"
    t.string "dietary_restrictions"
    t.string "allergies"
  end

  create_table "shipping_addresses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "contact_name"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "postal_code"
    t.string "city"
    t.string "state"
  end

  create_table "sports", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sports_on_deleted_at"
  end

  create_table "sports_users", id: false, force: :cascade do |t|
    t.bigint "sport_id", null: false
    t.bigint "user_id", null: false
    t.index ["sport_id"], name: "index_sports_users_on_sport_id"
    t.index ["user_id"], name: "index_sports_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "allow_password_change", default: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "nickname"
    t.string "image"
    t.string "email"
    t.json "tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "middle_initial"
    t.string "last_name"
    t.string "gender"
    t.string "role"
    t.string "badge_name"
    t.date "birth_date"
    t.datetime "deleted_at"
    t.string "profile_file_name"
    t.string "profile_content_type"
    t.integer "profile_file_size"
    t.datetime "profile_updated_at"
    t.string "status", default: "Active"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  add_foreign_key "association_informations", "users"
  add_foreign_key "billing_addresses", "users"
  add_foreign_key "contact_informations", "users"
  add_foreign_key "medical_informations", "users"
  add_foreign_key "shipping_addresses", "users"
end
