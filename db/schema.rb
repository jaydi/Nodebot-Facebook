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

ActiveRecord::Schema.define(version: 20160706080127) do

  create_table "users", force: :cascade do |t|
    t.string   "sender_id",  limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "users", ["sender_id"], name: "index_users_on_sender_id", length: {"sender_id"=>191}, using: :btree

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
