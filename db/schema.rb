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

ActiveRecord::Schema[7.1].define(version: 2025_10_05_021300) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blueprint_areas", force: :cascade do |t|
    t.bigint "exam_blueprint_id", null: false
    t.string "area", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["exam_blueprint_id", "position"], name: "index_blueprint_areas_on_exam_blueprint_id_and_position", unique: true
    t.index ["exam_blueprint_id"], name: "index_blueprint_areas_on_exam_blueprint_id"
  end

  create_table "blueprint_components", force: :cascade do |t|
    t.bigint "blueprint_area_id", null: false
    t.string "slug"
    t.string "title", null: false
    t.string "component_type", null: false
    t.integer "num_items", default: 0, null: false
    t.decimal "maximum_score", precision: 6, scale: 2, default: "0.0", null: false
    t.jsonb "json_rules", default: {}, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blueprint_area_id", "position"], name: "index_blueprint_components_on_area_and_position", unique: true
    t.index ["blueprint_area_id"], name: "index_blueprint_components_on_blueprint_area_id"
  end

  create_table "exam_blueprints", force: :cascade do |t|
    t.string "modality", null: false
    t.integer "year", null: false
    t.integer "version", default: 1, null: false
    t.string "status", default: "draft", null: false
    t.string "title", null: false
    t.text "notes"
    t.string "checksum"
    t.bigint "created_by_id", null: false
    t.datetime "published_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_exam_blueprints_on_created_by_id"
    t.index ["modality", "year", "version"], name: "index_exam_blueprints_on_modality_year_version", unique: true
    t.index ["modality", "year"], name: "index_exam_blueprints_unique_published", unique: true, where: "((status)::text = 'published'::text)"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.datetime "disabled_at"
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["disabled_at"], name: "index_users_on_disabled_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "blueprint_areas", "exam_blueprints"
  add_foreign_key "blueprint_components", "blueprint_areas"
  add_foreign_key "exam_blueprints", "users", column: "created_by_id"
end
