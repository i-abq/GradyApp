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

ActiveRecord::Schema[7.1].define(version: 2025_10_07_005804) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
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

  create_table "blueprint_rules", force: :cascade do |t|
    t.bigint "blueprint_id", null: false
    t.string "area", null: false
    t.string "component", null: false
    t.integer "quantity", default: 0, null: false
    t.decimal "max_points", precision: 8, scale: 4, default: "0.0", null: false
    t.string "rounding_mode", default: "nearest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blueprint_id", "area", "component"], name: "index_blueprint_rules_on_blueprint_area_component", unique: true
    t.index ["blueprint_id", "area"], name: "index_blueprint_rules_on_blueprint_id_and_area"
    t.index ["blueprint_id", "component"], name: "index_blueprint_rules_on_blueprint_id_and_component"
    t.index ["blueprint_id"], name: "index_blueprint_rules_on_blueprint_id"
  end

  create_table "blueprint_snapshots", force: :cascade do |t|
    t.bigint "blueprint_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.string "checksum", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blueprint_id"], name: "index_blueprint_snapshots_on_blueprint_id"
    t.index ["checksum"], name: "index_blueprint_snapshots_on_checksum", unique: true
    t.index ["created_at"], name: "index_blueprint_snapshots_on_created_at"
    t.index ["created_by_id"], name: "index_blueprint_snapshots_on_created_by_id"
  end

  create_table "blueprints", force: :cascade do |t|
    t.integer "year", null: false
    t.string "modality", default: "p2", null: false
    t.string "name", null: false
    t.string "status", default: "draft", null: false
    t.text "observations"
    t.integer "target_questions_per_area", default: 100, null: false
    t.decimal "target_points_per_area", precision: 8, scale: 2, default: "10.0", null: false
    t.datetime "published_at"
    t.string "version", default: "1.0.0", null: false
    t.bigint "created_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_blueprints_on_created_by_id"
    t.index ["status"], name: "index_blueprints_on_status"
    t.index ["year", "modality"], name: "index_blueprints_on_year_and_modality"
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

  create_table "question_alternatives", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "letter", null: false
    t.text "text", null: false
    t.boolean "correct", default: false, null: false
    t.text "distractor_justification"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "letter"], name: "index_question_alternatives_on_question_id_and_letter", unique: true
    t.index ["question_id"], name: "index_question_alternatives_on_question_id"
  end

  create_table "question_rubric_levels", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "letter", null: false
    t.integer "level_index", null: false
    t.integer "percentage", null: false
    t.text "criteria", null: false
    t.text "examples_evidence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "letter"], name: "index_rubric_levels_on_question_and_letter", unique: true
    t.index ["question_id", "level_index"], name: "index_rubric_levels_on_question_and_level", unique: true
    t.index ["question_id"], name: "index_question_rubric_levels_on_question_id"
  end

  create_table "questions", force: :cascade do |t|
    t.uuid "item_id", default: -> { "gen_random_uuid()" }, null: false
    t.integer "version", default: 1, null: false
    t.string "status", default: "draft", null: false
    t.string "question_type", null: false
    t.string "area", null: false
    t.string "theme", null: false
    t.integer "year_of_application"
    t.string "difficulty"
    t.string "level"
    t.string "source"
    t.string "usage_rights"
    t.jsonb "tags", default: [], null: false
    t.text "author_comment"
    t.text "statement", null: false
    t.boolean "shuffle_alternatives", default: true, null: false
    t.jsonb "omr_letter_map", default: {}, null: false
    t.boolean "anchored", default: false, null: false
    t.uuid "anchor_set_id"
    t.boolean "voidable", default: false, null: false
    t.decimal "maximum_score", precision: 8, scale: 2
    t.jsonb "percent_mapping", default: {}, null: false
    t.datetime "approved_on"
    t.bigint "author_id", null: false
    t.bigint "reviewer_id"
    t.bigint "approver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approver_id"], name: "index_questions_on_approver_id"
    t.index ["area"], name: "index_questions_on_area"
    t.index ["author_id"], name: "index_questions_on_author_id"
    t.index ["item_id"], name: "index_questions_on_item_id", unique: true
    t.index ["question_type"], name: "index_questions_on_question_type"
    t.index ["reviewer_id"], name: "index_questions_on_reviewer_id"
    t.index ["status"], name: "index_questions_on_status"
    t.index ["theme"], name: "index_questions_on_theme"
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
  add_foreign_key "blueprint_rules", "blueprints"
  add_foreign_key "blueprint_snapshots", "blueprints"
  add_foreign_key "blueprint_snapshots", "users", column: "created_by_id"
  add_foreign_key "blueprints", "users", column: "created_by_id"
  add_foreign_key "exam_blueprints", "users", column: "created_by_id"
  add_foreign_key "question_alternatives", "questions"
  add_foreign_key "question_rubric_levels", "questions"
  add_foreign_key "questions", "users", column: "approver_id"
  add_foreign_key "questions", "users", column: "author_id"
  add_foreign_key "questions", "users", column: "reviewer_id"
end
