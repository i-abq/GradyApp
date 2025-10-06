class CreateBlueprintSnapshots < ActiveRecord::Migration[7.1]
  def change
    create_table :blueprint_snapshots do |t|
      t.references :blueprint, null: false, foreign_key: true
      t.jsonb :payload, null: false, default: {}
      t.string :checksum, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :blueprint_snapshots, :checksum, unique: true
    add_index :blueprint_snapshots, :created_at
  end
end
