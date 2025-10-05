class CreateBlueprintComponents < ActiveRecord::Migration[7.1]
  def change
    create_table :blueprint_components do |t|
      t.references :blueprint_area, null: false, foreign_key: true
      t.string :slug
      t.string :title, null: false
      t.string :component_type, null: false
      t.integer :num_items, null: false, default: 0
      t.decimal :maximum_score, precision: 6, scale: 2, null: false, default: 0
      t.jsonb :json_rules, null: false, default: {}
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :blueprint_components, %i[blueprint_area_id position], unique: true,
                                   name: "index_blueprint_components_on_area_and_position"
  end
end
