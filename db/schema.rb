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

ActiveRecord::Schema.define(version: 20150510025133) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentication_providers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "description"
    t.boolean  "enabled"
  end

  add_index "authentication_providers", ["name"], name: "index_name_on_authentication_providers", using: :btree

  create_table "user_authentications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "authentication_provider_id"
    t.string   "uid"
    t.string   "token"
    t.datetime "token_expires_at"
    t.jsonb    "params"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "last_position"
  end

  add_index "user_authentications", ["authentication_provider_id"], name: "index_user_authentications_on_authentication_provider_id", using: :btree
  add_index "user_authentications", ["user_id"], name: "index_user_authentications_on_user_id", using: :btree

  create_table "user_keyword_hits", force: :cascade do |t|
    t.integer  "user_keyword_id"
    t.string   "provider"
    t.string   "uri"
    t.string   "content"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.float    "score"
  end

  add_index "user_keyword_hits", ["user_keyword_id"], name: "index_user_keyword_hits_on_user_keyword_id", using: :btree

  create_table "user_keywords", force: :cascade do |t|
    t.integer  "user_snippet_id"
    t.float    "relevance"
    t.string   "keyword"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "analysis_type"
  end

  add_index "user_keywords", ["user_snippet_id"], name: "index_user_keywords_on_user_snippet_id", using: :btree

  create_table "user_snippets", force: :cascade do |t|
    t.integer  "user_authentication_id"
    t.string   "title"
    t.string   "content"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.jsonb    "keywords"
  end

  add_index "user_snippets", ["user_authentication_id"], name: "index_user_snippets_on_user_authentication_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "mobile"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "user_keyword_hits", "user_keywords"
  add_foreign_key "user_keywords", "user_snippets"
  add_foreign_key "user_snippets", "user_authentications"
end
