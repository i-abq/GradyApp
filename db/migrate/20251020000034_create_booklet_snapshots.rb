class CreateBookletSnapshots < ActiveRecord::Migration[7.1]
  def change
    create_table :booklet_snapshots do |t|
      t.references :blueprint, null: false, foreign_key: true
      t.references :blueprint_snapshot, null: false, foreign_key: true
      t.string :area, null: false
      t.jsonb :payload, null: false, default: {}
      t.string :checksum, null: false
      t.references :generated_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :booklet_snapshots, :checksum, unique: true
  end
end
