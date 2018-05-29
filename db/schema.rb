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

ActiveRecord::Schema.define(version: 2018_05_29_180047) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agenda_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_agenda_types_on_deleted_at"
  end

  create_table "association_informations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "membership_type"
    t.string "membership_id"
    t.string "raking"
    t.string "affiliation"
    t.string "certification"
    t.string "company"
  end

  create_table "attendee_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_attendee_types_on_deleted_at"
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
    t.string "cell_phone"
    t.string "alternative_email"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "postal_code"
    t.string "state"
    t.string "city"
    t.string "work_phone"
    t.string "emergency_contact_full_name"
    t.string "emergency_contact_country_code_phone"
    t.string "emergency_contact_phone"
    t.string "country_code_work_phone"
  end

  create_table "event_discount_generals", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "code"
    t.float "discount"
    t.integer "limited"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_discount_personalizeds", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "email"
    t.string "code"
    t.float "discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_discounts", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.float "early_bird_registration"
    t.integer "early_bird_players"
    t.float "late_registration"
    t.integer "late_players"
    t.float "on_site_registration"
    t.integer "on_site_players"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_payment_informations", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.string "bank_name"
    t.string "bank_account"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_payment_methods", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.float "enrollment_fee"
    t.float "bracket_fee"
    t.string "currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_event_types_on_deleted_at"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "venue_id"
    t.bigint "event_type_id"
    t.string "title"
    t.string "icon_file_name"
    t.string "icon_content_type"
    t.integer "icon_file_size"
    t.datetime "icon_updated_at"
    t.text "description"
    t.date "start_date"
    t.date "end_date"
    t.string "visibility"
    t.boolean "requires_access_code", default: false
    t.string "event_url"
    t.boolean "is_event_sanctioned", default: false
    t.text "sanctions"
    t.string "organization_name"
    t.string "organization_url"
    t.boolean "is_determine_later_venue", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "status", default: "Active"
    t.index ["deleted_at"], name: "index_events_on_deleted_at"
  end

  create_table "events_regions", id: false, force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "region_id", null: false
    t.index ["event_id"], name: "index_events_regions_on_event_id"
    t.index ["region_id"], name: "index_events_regions_on_region_id"
  end

  create_table "events_sports", id: false, force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "sport_id", null: false
    t.index ["event_id"], name: "index_events_sports_on_event_id"
    t.index ["sport_id"], name: "index_events_sports_on_sport_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name"
    t.string "locale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_languages_on_deleted_at"
  end

  create_table "medical_informations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "insurance_provider"
    t.string "insurance_policy_number"
    t.string "group_id"
    t.string "primary_physician_full_name"
    t.string "primary_physician_country_code_phone"
    t.string "primary_physician_phone"
    t.string "dietary_restrictions"
    t.string "allergies"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.string "base"
    t.string "territoy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_regions_on_deleted_at"
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

  create_table "sponsors", force: :cascade do |t|
    t.string "company_name"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.string "brand"
    t.string "product"
    t.string "franchise_brand"
    t.string "business_category"
    t.string "geography"
    t.text "description"
    t.string "contact_name"
    t.string "country_code"
    t.string "phone"
    t.string "email"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "postal_code"
    t.string "state"
    t.string "city"
    t.string "work_country_code"
    t.string "work_phone"
    t.string "status", default: "Active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_sponsors_on_deleted_at"
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

  create_table "sports_venues", id: false, force: :cascade do |t|
    t.bigint "sport_id", null: false
    t.bigint "venue_id", null: false
    t.index ["sport_id"], name: "index_sports_venues_on_sport_id"
    t.index ["venue_id"], name: "index_sports_venues_on_venue_id"
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
    t.boolean "is_receive_text", default: false
    t.string "pin"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

  create_table "venue_days", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.string "day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "time_start"
    t.time "time_end"
  end

  create_table "venue_facility_managements", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.string "primary_contact_name"
    t.string "primary_contact_email"
    t.string "primary_contact_country_code"
    t.string "primary_contact_phone_number"
    t.string "secondary_contact_name"
    t.string "secondary_contact_email"
    t.string "secondary_contact_country_code"
    t.string "secondary_contact_phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "venue_pictures", force: :cascade do |t|
    t.bigint "venue_id", null: false
    t.string "picture_file_name"
    t.string "picture_content_type"
    t.integer "picture_file_size"
    t.datetime "picture_updated_at"
  end

  create_table "venues", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.string "country_code"
    t.string "phone_number"
    t.string "link"
    t.string "facility"
    t.text "description"
    t.string "space"
    t.text "latitude"
    t.text "longitude"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "postal_code"
    t.string "city"
    t.string "state"
    t.string "country"
    t.date "availability_date_start"
    t.date "availability_date_end"
    t.string "availability_time_zone"
    t.text "restrictions"
    t.boolean "is_insurance_requirements"
    t.text "insurance_requirements"
    t.boolean "is_decorations"
    t.text "decorations"
    t.boolean "is_vehicles"
    t.integer "vehicles"
    t.string "status", default: "Active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_venues_on_deleted_at"
  end

  add_foreign_key "association_informations", "users"
  add_foreign_key "billing_addresses", "users"
  add_foreign_key "contact_informations", "users"
  add_foreign_key "medical_informations", "users"
  add_foreign_key "shipping_addresses", "users"
end
