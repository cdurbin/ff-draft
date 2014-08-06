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

ActiveRecord::Schema.define(version: 20140805223538) do

  create_table "defenses", primary_key: "player_id", force: true do |t|
    t.string   "display_name"
    t.integer  "fantasy_points"
    t.integer  "fumble_rec"
    t.integer  "td"
    t.integer  "interceptions"
    t.integer  "sacks"
    t.integer  "special_team_td"
    t.string   "team"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kickers", primary_key: "player_id", force: true do |t|
    t.string   "display_name"
    t.integer  "fantasy_points"
    t.integer  "fg"
    t.integer  "xp"
    t.string   "team"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "quarterbacks", primary_key: "player_id", force: true do |t|
    t.string   "display_name"
    t.integer  "fantasy_points"
    t.integer  "attempts"
    t.integer  "completions"
    t.integer  "passing_int"
    t.integer  "passing_td"
    t.integer  "passing_yards"
    t.integer  "rush_td"
    t.integer  "rush_yards"
    t.string   "team"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "running_backs", primary_key: "player_id", force: true do |t|
    t.string   "display_name"
    t.integer  "fantasy_points"
    t.integer  "fumbles"
    t.integer  "rec"
    t.integer  "rec_td"
    t.integer  "rec_yards"
    t.integer  "rush_att"
    t.integer  "rush_td"
    t.integer  "rush_yards"
    t.string   "team"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tight_ends", primary_key: "player_id", force: true do |t|
    t.string   "display_name"
    t.integer  "fantasy_points"
    t.integer  "fumbles"
    t.integer  "rec"
    t.integer  "rec_td"
    t.integer  "rec_yards"
    t.integer  "rush_att"
    t.integer  "rush_td"
    t.integer  "rush_yards"
    t.string   "team"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "wide_receivers", primary_key: "player_id", force: true do |t|
    t.string   "display_name"
    t.integer  "fantasy_points"
    t.integer  "fumbles"
    t.integer  "rec"
    t.integer  "rec_td"
    t.integer  "rec_yards"
    t.integer  "rush_att"
    t.integer  "rush_td"
    t.integer  "rush_yards"
    t.string   "team"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
