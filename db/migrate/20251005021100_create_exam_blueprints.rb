class CreateExamBlueprints < ActiveRecord::Migration[7.1]
  def change
    create_table :exam_blueprints do |t|
      t.string :modality, null: false
      t.integer :year, null: false
      t.integer :version, null: false, default: 1
      t.string :status, null: false, default: "draft"
      t.string :title, null: false
      t.text :notes
      t.string :checksum
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.datetime :published_on

      t.timestamps
    end

    add_index :exam_blueprints, %i[modality year version], unique: true, name: "index_exam_blueprints_on_modality_year_version"
    add_index :exam_blueprints, %i[modality year], unique: true, where: "status = 'published'", name: "index_exam_blueprints_unique_published"
  end
end
