class CreateBlueprintRules < ActiveRecord::Migration[7.1]
  def change
    create_table :blueprint_rules do |t|
      t.references :blueprint, null: false, foreign_key: true
      t.string :area, null: false
      t.string :component, null: false
      t.integer :quantity, null: false, default: 0
      t.decimal :max_points, precision: 8, scale: 4, null: false, default: "0.0"
      t.string :rounding_mode, null: false, default: "nearest"

      t.timestamps
    end

    add_index :blueprint_rules, [:blueprint_id, :area]
    add_index :blueprint_rules, [:blueprint_id, :component]
    add_index :blueprint_rules, [:blueprint_id, :area, :component], unique: true, name: "index_blueprint_rules_on_blueprint_area_component"
  end
end
