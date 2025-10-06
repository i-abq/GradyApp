class CreateBlueprints < ActiveRecord::Migration[7.1]
  def change
    create_table :blueprints do |t|
      t.integer :year, null: false
      t.string :modality, null: false, default: "p2"
      t.string :name, null: false
      t.string :status, null: false, default: "draft"
      t.text :observations
      t.integer :target_questions_per_area, null: false, default: 100
      t.decimal :target_points_per_area, precision: 8, scale: 2, null: false, default: "10.0"
      t.datetime :published_at
      t.string :version, null: false, default: "1.0.0"
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :blueprints, [:year, :modality]
    add_index :blueprints, :status
  end
end
