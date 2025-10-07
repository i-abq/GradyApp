class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.uuid :item_id, null: false, default: "gen_random_uuid()"
      t.integer :version, null: false, default: 1
      t.string :status, null: false, default: "draft"
      t.string :question_type, null: false
      t.string :area, null: false
      t.string :theme, null: false
      t.integer :year_of_application
      t.string :difficulty
      t.string :level
      t.string :source
      t.string :usage_rights
      t.jsonb :tags, null: false, default: []
      t.text :author_comment
      t.text :statement, null: false
      t.boolean :shuffle_alternatives, null: false, default: true
      t.jsonb :omr_letter_map, null: false, default: {}
      t.boolean :anchored, null: false, default: false
      t.uuid :anchor_set_id
      t.boolean :voidable, null: false, default: false
      t.decimal :maximum_score, precision: 8, scale: 2
      t.jsonb :percent_mapping, null: false, default: {}
      t.datetime :approved_on
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :reviewer, foreign_key: { to_table: :users }
      t.references :approver, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :questions, :item_id, unique: true
    add_index :questions, :status
    add_index :questions, :question_type
    add_index :questions, :area
    add_index :questions, :theme
  end
end
