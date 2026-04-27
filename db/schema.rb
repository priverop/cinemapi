# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_27_125425) do
  create_table "movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "data_source", default: 0, null: false
    t.text "description"
    t.string "directors"
    t.integer "duration"
    t.string "genre"
    t.boolean "is_enabled", default: true, null: false
    t.string "poster"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "showtimes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "language", default: 0, null: false
    t.integer "movie_id", null: false
    t.datetime "showtime"
    t.integer "theater_id", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id", "theater_id", "showtime"], name: "index_showtimes_on_movie_theater_datetime"
    t.index ["movie_id"], name: "index_showtimes_on_movie_id"
    t.index ["theater_id"], name: "index_showtimes_on_theater_id"
  end

  create_table "theaters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "discounted_days"
    t.decimal "discounted_price"
    t.boolean "is_enabled", default: true, null: false
    t.string "location"
    t.string "name"
    t.decimal "price"
    t.integer "scraper_external_id"
    t.integer "scraper_key"
    t.datetime "updated_at", null: false
    t.string "website"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "showtimes", "movies"
  add_foreign_key "showtimes", "theaters"
end
