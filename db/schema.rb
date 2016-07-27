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

ActiveRecord::Schema.define(version: 20160712052752) do

  create_table "celebs", force: :cascade do |t|
    t.string   "email",       limit: 255,                  null: false
    t.string   "password",    limit: 255,                  null: false
    t.string   "name",        limit: 255
    t.string   "profile_pic", limit: 255
    t.integer  "price",       limit: 4,   default: 100000, null: false
    t.integer  "status",      limit: 4,                    null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "celebs", ["email"], name: "index_celebs_on_email", length: {"email"=>191}, using: :btree
  add_index "celebs", ["name"], name: "index_celebs_on_name", length: {"name"=>191}, using: :btree
  add_index "celebs", ["status"], name: "index_celebs_on_status", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "initial_message_id", limit: 4
    t.integer  "sending_user_id",    limit: 4,     null: false
    t.integer  "receiving_user_id",  limit: 4,     null: false
    t.text     "text",               limit: 65535
    t.string   "video_url",          limit: 255
    t.integer  "status",             limit: 4,     null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "messages", ["initial_message_id"], name: "index_messages_on_initial_message_id", using: :btree
  add_index "messages", ["receiving_user_id"], name: "index_messages_on_receiving_user_id", using: :btree
  add_index "messages", ["sending_user_id"], name: "index_messages_on_sending_user_id", using: :btree
  add_index "messages", ["status"], name: "index_messages_on_status", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "message_id",        limit: 4, null: false
    t.integer  "sending_user_id",   limit: 4, null: false
    t.integer  "receiving_user_id", limit: 4, null: false
    t.integer  "pay_amount",        limit: 4, null: false
    t.integer  "status",            limit: 4, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "payments", ["message_id"], name: "index_payments_on_message_id", using: :btree
  add_index "payments", ["receiving_user_id"], name: "index_payments_on_receiving_user_id", using: :btree
  add_index "payments", ["sending_user_id"], name: "index_payments_on_sending_user_id", using: :btree
  add_index "payments", ["status"], name: "index_payments_on_status", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "sender_id",  limit: 255, null: false
    t.integer  "celeb_id",   limit: 4
    t.string   "name",       limit: 255, null: false
    t.integer  "status",     limit: 4,   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "users", ["sender_id"], name: "index_users_on_sender_id", length: {"sender_id"=>191}, using: :btree
  add_index "users", ["status"], name: "index_users_on_status", using: :btree

  create_table "web_messages", force: :cascade do |t|
    t.string   "message_id",     limit: 255
    t.string   "sender_id",      limit: 255,   null: false
    t.integer  "message_type",   limit: 4,     null: false
    t.integer  "sequence",       limit: 4
    t.text     "text",           limit: 65535
    t.string   "payload",        limit: 255
    t.integer  "sent_timestamp", limit: 8,     null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "web_messages", ["sender_id"], name: "index_web_messages_on_sender_id", length: {"sender_id"=>191}, using: :btree

end
