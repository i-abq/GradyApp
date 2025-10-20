class CreateBlueprintRestrictions < ActiveRecord::Migration[7.1]
  def change
    create_table :blueprint_restrictions do |t|
      t.references :blueprint, null: false, foreign_key: true
      t.string :area, null: false
      t.string :component, null: false
      t.jsonb :include_tags, null: false, default: []
      t.jsonb :exclude_tags, null: false, default: []
      t.jsonb :sources, null: false, default: []
      t.jsonb :difficulty_mix, null: false, default: {}
      t.integer :reuse_years_block
      t.boolean :allow_reuse, null: false, default: true

      t.timestamps
    end

    add_index :blueprint_restrictions, [:blueprint_id, :area, :component], name: "index_blueprint_restrictions_on_blueprint_area_component"
  end
end
