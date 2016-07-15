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

ActiveRecord::Schema.define(version: 20150713201619) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.string   "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "actions", ["content"], name: "index_actions_on_content", unique: true, using: :btree

  create_table "activities", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "picture"
    t.integer  "action_id"
    t.datetime "finished_at"
  end

  add_index "activities", ["action_id"], name: "index_activities_on_action_id", using: :btree
  add_index "activities", ["user_id", "created_at"], name: "index_activities_on_user_id_and_created_at", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "birds", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "nest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "birds", ["nest_id"], name: "index_birds_on_nest_id", using: :btree
  add_index "birds", ["user_id", "nest_id"], name: "index_birds_on_user_id_and_nest_id", unique: true, using: :btree
  add_index "birds", ["user_id"], name: "index_birds_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "content"
    t.integer  "user_id"
    t.integer  "activity_id"
    t.integer  "parent_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "depth"
  end

  add_index "comments", ["activity_id"], name: "index_comments_on_activity_id", using: :btree
  add_index "comments", ["parent_id"], name: "index_comments_on_parent_id", using: :btree
  add_index "comments", ["user_id", "created_at"], name: "index_comments_on_user_id_and_created_at", unique: true, using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "nests", force: :cascade do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "action_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "nests", ["action_id"], name: "index_nests_on_action_id", using: :btree
  add_index "nests", ["user_id", "action_id"], name: "index_nests_on_user_id_and_action_id", unique: true, using: :btree
  add_index "nests", ["user_id"], name: "index_nests_on_user_id", using: :btree

  create_table "rates", force: :cascade do |t|
    t.integer  "rating_id"
    t.integer  "user_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "up",         default: true
  end

  add_index "rates", ["rating_id", "user_id"], name: "index_rates_on_rating_id_and_user_id", unique: true, using: :btree
  add_index "rates", ["rating_id"], name: "index_rates_on_rating_id", using: :btree
  add_index "rates", ["user_id"], name: "index_rates_on_user_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "post_id"
    t.string   "post_type"
  end

  add_index "ratings", ["post_type", "post_id"], name: "index_ratings_on_post_type_and_post_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.integer  "tracker_id"
    t.integer  "tracked_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "relationships", ["tracked_id"], name: "index_relationships_on_tracked_id", using: :btree
  add_index "relationships", ["tracker_id", "tracked_id"], name: "index_relationships_on_tracker_id_and_tracked_id", unique: true, using: :btree
  add_index "relationships", ["tracker_id"], name: "index_relationships_on_tracker_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "email"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",             default: false
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "picture"
    t.boolean  "active"
    t.integer  "active_id"
    t.boolean  "activation_route",  default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  add_foreign_key "activities", "users"
  add_foreign_key "birds", "nests"
  add_foreign_key "birds", "users"
  add_foreign_key "comments", "activities"
  add_foreign_key "comments", "users"
  add_foreign_key "nests", "actions"
  add_foreign_key "nests", "users"
  add_foreign_key "rates", "ratings"
  add_foreign_key "rates", "users"
end
