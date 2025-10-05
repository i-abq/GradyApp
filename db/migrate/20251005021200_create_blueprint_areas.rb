class CreateBlueprintAreas < ActiveRecord::Migration[7.1]
  def change
    create_table :blueprint_areas do |t|
      t.references :exam_blueprint, null: false, foreign_key: true
      t.string :area, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :blueprint_areas, %i[exam_blueprint_id position], unique: true
  end
end
