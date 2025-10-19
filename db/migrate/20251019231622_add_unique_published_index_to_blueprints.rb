class AddUniquePublishedIndexToBlueprints < ActiveRecord::Migration[7.1]
  INDEX_NAME = "index_blueprints_on_year_modality_published"

  def up
    add_index :blueprints, [:year, :modality], unique: true, name: INDEX_NAME, where: "status = 'published'"
  end

  def down
    remove_index :blueprints, name: INDEX_NAME if index_exists?(:blueprints, nil, name: INDEX_NAME)
  end
end
