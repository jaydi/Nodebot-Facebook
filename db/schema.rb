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

ActiveRecord::Schema.define(version: 20161102064758) do

  create_table "banks", force: :cascade do |t|
    t.string   "name",       limit: 36
    t.string   "code",       limit: 8
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "celebs", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "email",                                                         null: false
    t.string   "encrypted_password",                                            null: false
    t.string   "encrypted_password_iv",                                         null: false
    t.string   "name"
    t.string   "profile_pic"
    t.integer  "price",                                         default: 10000, null: false
    t.integer  "balance",                                       default: 0,     null: false
    t.decimal  "commission_rate",       precision: 5, scale: 2, default: 30.0,  null: false
    t.string   "auth_token"
    t.datetime "auth_tokened_at"
    t.integer  "status",                                                        null: false
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
  end

  add_index "celebs", ["auth_token"], name: "index_celebs_on_auth_token"
  add_index "celebs", ["email"], name: "index_celebs_on_email"
  add_index "celebs", ["name"], name: "index_celebs_on_name"
  add_index "celebs", ["status"], name: "index_celebs_on_status"

  create_table "exchange_requests", force: :cascade do |t|
    t.integer  "celeb_id",                    null: false
    t.integer  "bank_id",                     null: false
    t.string   "account_holder",              null: false
    t.string   "encrypted_account_number",    null: false
    t.string   "encrypted_account_number_iv", null: false
    t.integer  "amount",                      null: false
    t.integer  "status",                      null: false
    t.string   "failure_reason"
    t.datetime "processed_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "initial_message_id"
    t.integer  "sending_user_id",    null: false
    t.integer  "receiving_user_id",  null: false
    t.text     "text"
    t.string   "video_url"
    t.integer  "kind",               null: false
    t.integer  "status",             null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "messages", ["initial_message_id"], name: "index_messages_on_initial_message_id"
  add_index "messages", ["kind"], name: "index_messages_on_kind"
  add_index "messages", ["receiving_user_id"], name: "index_messages_on_receiving_user_id"
  add_index "messages", ["sending_user_id"], name: "index_messages_on_sending_user_id"
  add_index "messages", ["status"], name: "index_messages_on_status"

  create_table "payments", force: :cascade do |t|
    t.integer  "message_id",                              null: false
    t.integer  "pay_amount",                              null: false
    t.decimal  "commission_rate", precision: 5, scale: 2, null: false
    t.integer  "status",                                  null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "payments", ["message_id"], name: "index_payments_on_message_id"
  add_index "payments", ["status"], name: "index_payments_on_status"

  create_table "users", force: :cascade do |t|
    t.string   "sender_id",  null: false
    t.string   "name",       null: false
    t.integer  "status",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["sender_id"], name: "index_users_on_sender_id"
  add_index "users", ["status"], name: "index_users_on_status"

  create_table "web_messages", force: :cascade do |t|
    t.string   "message_id"
    t.string   "sender_id",                null: false
    t.integer  "message_type",             null: false
    t.integer  "sequence"
    t.text     "text"
    t.string   "payload"
    t.integer  "sent_timestamp", limit: 8, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "web_messages", ["sender_id"], name: "index_web_messages_on_sender_id"

end
