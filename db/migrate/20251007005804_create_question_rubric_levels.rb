class CreateQuestionRubricLevels < ActiveRecord::Migration[7.1]
  def change
    create_table :question_rubric_levels do |t|
      t.references :question, null: false, foreign_key: true
      t.string :letter, null: false
      t.integer :level_index, null: false
      t.integer :percentage, null: false
      t.text :criteria, null: false
      t.text :examples_evidence

      t.timestamps
    end

    add_index :question_rubric_levels, [:question_id, :letter], unique: true, name: "index_rubric_levels_on_question_and_letter"
    add_index :question_rubric_levels, [:question_id, :level_index], unique: true, name: "index_rubric_levels_on_question_and_level"
  end
end
