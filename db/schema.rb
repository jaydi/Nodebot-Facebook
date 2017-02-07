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

ActiveRecord::Schema.define(version: 20170110094920) do

  create_table "banks", force: :cascade do |t|
    t.string   "name",       limit: 36
    t.string   "code",       limit: 8
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "exchange_requests", force: :cascade do |t|
    t.integer  "user_id",                     null: false
    t.integer  "bank_id",                     null: false
    t.string   "requester",                   null: false
    t.string   "identity_string",             null: false
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
    t.integer  "sender_id",          null: false
    t.integer  "receiver_id",        null: false
    t.text     "text"
    t.string   "video_url"
    t.integer  "kind",               null: false
    t.integer  "status",             null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "messages", ["initial_message_id"], name: "index_messages_on_initial_message_id"
  add_index "messages", ["kind"], name: "index_messages_on_kind"
  add_index "messages", ["receiver_id"], name: "index_messages_on_receiver_id"
  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id"
  add_index "messages", ["status"], name: "index_messages_on_status"

  create_table "payments", force: :cascade do |t|
    t.integer  "message_id",                              null: false
    t.integer  "sender_id",                               null: false
    t.integer  "receiver_id",                             null: false
    t.integer  "pay_amount",                              null: false
    t.decimal  "commission_rate", precision: 5, scale: 2, null: false
    t.string   "failure_reason"
    t.integer  "status",                                  null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "payments", ["message_id"], name: "index_payments_on_message_id"
  add_index "payments", ["receiver_id"], name: "index_payments_on_receiver_id"
  add_index "payments", ["sender_id"], name: "index_payments_on_sender_id"
  add_index "payments", ["status"], name: "index_payments_on_status"

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], name: "index_roles_on_name"

  create_table "users", force: :cascade do |t|
    t.string   "messenger_id"
    t.string   "profile_pic"
    t.string   "name"
    t.integer  "balance",                                             default: 0,     null: false
    t.integer  "price",                                               default: 10000, null: false
    t.decimal  "commission_rate",             precision: 5, scale: 2, default: 30.0,  null: false
    t.boolean  "is_partner",                                          default: false, null: false
    t.boolean  "partner_agreements_accepted",                         default: false, null: false
    t.boolean  "user_agreements_accepted",                            default: false, null: false
    t.integer  "status",                                                              null: false
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.string   "email",                                               default: "",    null: false
    t.string   "encrypted_password",                                  default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                       default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["is_partner"], name: "index_users_on_is_partner"
  add_index "users", ["messenger_id"], name: "index_users_on_messenger_id"
  add_index "users", ["name"], name: "index_users_on_name"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["status"], name: "index_users_on_status"

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"

  create_table "web_messages", force: :cascade do |t|
    t.string   "message_id"
    t.string   "messenger_id",             null: false
    t.integer  "message_type",             null: false
    t.integer  "sequence"
    t.text     "text"
    t.string   "payload"
    t.integer  "sent_timestamp", limit: 8, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "web_messages", ["messenger_id"], name: "index_web_messages_on_messenger_id"

end
