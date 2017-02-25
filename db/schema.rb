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

ActiveRecord::Schema.define(version: 20170225115652) do

  create_table "banks", force: :cascade do |t|
    t.string   "name",       limit: 36
    t.string   "code",       limit: 8
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "exchange_requests", force: :cascade do |t|
    t.integer  "user_id",                     limit: 4,   null: false
    t.integer  "bank_id",                     limit: 4,   null: false
    t.string   "requester",                   limit: 255, null: false
    t.string   "identity_string",             limit: 255, null: false
    t.string   "account_holder",              limit: 255, null: false
    t.string   "encrypted_account_number",    limit: 255, null: false
    t.string   "encrypted_account_number_iv", limit: 255, null: false
    t.integer  "amount",                      limit: 4,   null: false
    t.integer  "status",                      limit: 4,   null: false
    t.string   "failure_reason",              limit: 255
    t.datetime "processed_at"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "initial_message_id", limit: 4
    t.integer  "sender_id",          limit: 4
    t.string   "sender_name",        limit: 255,   default: "", null: false
    t.integer  "receiver_id",        limit: 4
    t.string   "receiver_name",      limit: 255,   default: "", null: false
    t.text     "text",               limit: 65535
    t.string   "video_url",          limit: 255
    t.integer  "kind",               limit: 4,                  null: false
    t.integer  "status",             limit: 4,                  null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  add_index "messages", ["initial_message_id"], name: "index_messages_on_initial_message_id", using: :btree
  add_index "messages", ["kind"], name: "index_messages_on_kind", using: :btree
  add_index "messages", ["receiver_id"], name: "index_messages_on_receiver_id", using: :btree
  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id", using: :btree
  add_index "messages", ["status"], name: "index_messages_on_status", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "message_id",      limit: 4,                           null: false
    t.integer  "sender_id",       limit: 4,                           null: false
    t.integer  "receiver_id",     limit: 4,                           null: false
    t.integer  "pay_amount",      limit: 4,                           null: false
    t.decimal  "commission_rate",             precision: 5, scale: 2, null: false
    t.string   "failure_reason",  limit: 255
    t.integer  "status",          limit: 4,                           null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "payments", ["message_id"], name: "index_payments_on_message_id", using: :btree
  add_index "payments", ["receiver_id"], name: "index_payments_on_receiver_id", using: :btree
  add_index "payments", ["sender_id"], name: "index_payments_on_sender_id", using: :btree
  add_index "payments", ["status"], name: "index_payments_on_status", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "messenger_id",                limit: 255
    t.string   "profile_pic",                 limit: 255
    t.string   "name",                        limit: 255
    t.integer  "balance",                     limit: 4,                           default: 0,     null: false
    t.integer  "price",                       limit: 4,                           default: 10000, null: false
    t.decimal  "commission_rate",                         precision: 5, scale: 2, default: 30.0,  null: false
    t.boolean  "is_partner",                                                      default: false, null: false
    t.boolean  "partner_agreements_accepted",                                     default: false, null: false
    t.boolean  "user_agreements_accepted",                                        default: false, null: false
    t.integer  "status",                      limit: 4,                                           null: false
    t.datetime "created_at",                                                                      null: false
    t.datetime "updated_at",                                                                      null: false
    t.string   "email",                       limit: 255,                         default: "",    null: false
    t.string   "encrypted_password",          limit: 255,                         default: "",    null: false
    t.string   "reset_password_token",        limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               limit: 4,                           default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",          limit: 255
    t.string   "last_sign_in_ip",             limit: 255
  end

  add_index "users", ["is_partner"], name: "index_users_on_is_partner", using: :btree
  add_index "users", ["messenger_id"], name: "index_users_on_messenger_id", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["status"], name: "index_users_on_status", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "web_messages", force: :cascade do |t|
    t.string   "message_id",     limit: 255
    t.string   "messenger_id",   limit: 255,   null: false
    t.integer  "message_type",   limit: 4,     null: false
    t.integer  "sequence",       limit: 4
    t.text     "text",           limit: 65535
    t.string   "payload",        limit: 255
    t.integer  "sent_timestamp", limit: 8,     null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "web_messages", ["messenger_id"], name: "index_web_messages_on_messenger_id", using: :btree

end
