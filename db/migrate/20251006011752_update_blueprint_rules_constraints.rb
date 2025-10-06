class UpdateBlueprintRulesConstraints < ActiveRecord::Migration[7.1]
  def up
    change_column :blueprint_rules, :area, :string, null: false
    change_column :blueprint_rules, :component, :string, null: false

    change_column_default :blueprint_rules, :quantity, from: nil, to: 0
    change_column_null :blueprint_rules, :quantity, false, 0

    change_column :blueprint_rules, :max_points, :decimal, precision: 8, scale: 4, default: "0.0", null: false

    change_column_default :blueprint_rules, :rounding_mode, from: nil, to: "nearest"
    change_column_null :blueprint_rules, :rounding_mode, false, "nearest"

    add_index :blueprint_rules, [:blueprint_id, :area] unless index_exists?(:blueprint_rules, [:blueprint_id, :area])
    add_index :blueprint_rules, [:blueprint_id, :component] unless index_exists?(:blueprint_rules, [:blueprint_id, :component])
    add_index :blueprint_rules, [:blueprint_id, :area, :component], unique: true, name: "index_blueprint_rules_on_blueprint_area_component" unless index_exists?(:blueprint_rules, [:blueprint_id, :area, :component], unique: true)
  end

  def down
    remove_index :blueprint_rules, name: "index_blueprint_rules_on_blueprint_area_component" if index_exists?(:blueprint_rules, name: "index_blueprint_rules_on_blueprint_area_component")
    remove_index :blueprint_rules, [:blueprint_id, :component] if index_exists?(:blueprint_rules, [:blueprint_id, :component])
    remove_index :blueprint_rules, [:blueprint_id, :area] if index_exists?(:blueprint_rules, [:blueprint_id, :area])

    change_column_null :blueprint_rules, :rounding_mode, true
    change_column_default :blueprint_rules, :rounding_mode, from: "nearest", to: nil

    change_column :blueprint_rules, :max_points, :decimal
    change_column_null :blueprint_rules, :max_points, true
    change_column_default :blueprint_rules, :max_points, from: "0.0", to: nil

    change_column_null :blueprint_rules, :quantity, true
    change_column_default :blueprint_rules, :quantity, from: 0, to: nil

    change_column_null :blueprint_rules, :component, true
    change_column_null :blueprint_rules, :area, true
  end
end
