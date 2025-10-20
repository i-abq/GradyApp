class CreateBlueprintScoringPolicies < ActiveRecord::Migration[7.1]
  def change
    create_table :blueprint_scoring_policies do |t|
      t.references :blueprint, null: false, foreign_key: true
      t.decimal :wrong_penalty, precision: 8, scale: 4, null: false, default: 0.0
      t.string :blank_behavior, null: false, default: "zero"
      t.decimal :blank_points, precision: 8, scale: 4
      t.string :normalization, null: false, default: "none"
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :blueprint_scoring_policies, :blueprint_id, unique: true
  end
end
