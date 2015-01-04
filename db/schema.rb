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

ActiveRecord::Schema.define(version: 20141226224502) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "adminpack"

  create_table "deliveries", force: true do |t|
    t.integer  "user_id"
    t.string   "kindle_email"
    t.integer  "frequency",         default: 0
    t.integer  "day",               default: 7
    t.integer  "hour"
    t.string   "time_zone"
    t.integer  "option",            default: 0
    t.integer  "count"
    t.boolean  "archive_delivered", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deliveries", ["user_id"], name: "index_deliveries_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
