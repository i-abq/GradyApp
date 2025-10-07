class CreateQuestionAlternatives < ActiveRecord::Migration[7.1]
  def change
    create_table :question_alternatives do |t|
      t.references :question, null: false, foreign_key: true
      t.string :letter, null: false
      t.text :text, null: false
      t.boolean :correct, null: false, default: false
      t.text :distractor_justification
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :question_alternatives, [:question_id, :letter], unique: true
  end
end
