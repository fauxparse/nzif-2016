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

ActiveRecord::Schema.define(version: 20160619002642) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "type"
    t.integer  "festival_id"
    t.string   "name"
    t.string   "slug"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["festival_id"], name: "index_activities_on_festival_id", using: :btree
  end

  create_table "allocations", force: :cascade do |t|
    t.integer "package_id"
    t.string  "activity_type_name", limit: 32
    t.integer "maximum",                       default: 0
    t.index ["package_id", "activity_type_name"], name: "index_allocations_on_package_id_and_activity_type_name", unique: true, using: :btree
    t.index ["package_id"], name: "index_allocations_on_package_id", using: :btree
  end

  create_table "facilitators", force: :cascade do |t|
    t.integer "participant_id"
    t.integer "activity_id"
    t.integer "position",       default: 0
    t.index ["activity_id"], name: "index_facilitators_on_activity_id", using: :btree
    t.index ["participant_id"], name: "index_facilitators_on_participant_id", using: :btree
  end

  create_table "festivals", force: :cascade do |t|
    t.integer  "year"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year"], name: "index_festivals_on_year", using: :btree
  end

  create_table "packages", force: :cascade do |t|
    t.integer  "festival_id"
    t.string   "name"
    t.string   "slug",        limit: 128
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "position",                default: 0
    t.index ["festival_id"], name: "index_packages_on_festival_id", using: :btree
  end

  create_table "participants", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_participants_on_user_id", using: :btree
  end

  create_table "registrations", force: :cascade do |t|
    t.integer  "participant_id", null: false
    t.integer  "festival_id",    null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "package_id"
    t.index ["festival_id", "participant_id"], name: "index_registrations_on_festival_id_and_participant_id", using: :btree
    t.index ["festival_id"], name: "index_registrations_on_festival_id", using: :btree
    t.index ["package_id"], name: "index_registrations_on_package_id", using: :btree
    t.index ["participant_id", "festival_id"], name: "index_registrations_on_participant_id_and_festival_id", using: :btree
    t.index ["participant_id"], name: "index_registrations_on_participant_id", using: :btree
  end

  create_table "schedules", force: :cascade do |t|
    t.integer  "activity_id"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer  "position",         default: 0
    t.integer  "selections_count", default: 0
    t.integer  "maximum"
    t.index ["activity_id"], name: "index_schedules_on_activity_id", using: :btree
    t.index ["starts_at", "ends_at", "activity_id"], name: "index_schedules_on_starts_at_and_ends_at_and_activity_id", unique: true, using: :btree
  end

  create_table "selections", force: :cascade do |t|
    t.integer  "registration_id"
    t.integer  "schedule_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["registration_id", "schedule_id"], name: "index_selections_on_registration_id_and_schedule_id", unique: true, using: :btree
    t.index ["registration_id"], name: "index_selections_on_registration_id", using: :btree
    t.index ["schedule_id"], name: "index_selections_on_schedule_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "name"
    t.boolean  "admin",                  default: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "venues", force: :cascade do |t|
    t.string  "name"
    t.string  "address"
    t.decimal "latitude",  precision: 9, scale: 6
    t.decimal "longitude", precision: 9, scale: 6
    t.integer "position"
  end

  add_foreign_key "activities", "festivals"
  add_foreign_key "allocations", "packages"
  add_foreign_key "facilitators", "activities"
  add_foreign_key "facilitators", "participants"
  add_foreign_key "packages", "festivals"
  add_foreign_key "participants", "users", on_delete: :nullify
  add_foreign_key "registrations", "festivals", on_delete: :cascade
  add_foreign_key "registrations", "packages"
  add_foreign_key "registrations", "participants", on_delete: :cascade
  add_foreign_key "schedules", "activities", on_delete: :cascade
  add_foreign_key "selections", "registrations"
  add_foreign_key "selections", "schedules"
end
