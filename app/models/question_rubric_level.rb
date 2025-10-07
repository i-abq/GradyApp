# frozen_string_literal: true

class QuestionRubricLevel < ApplicationRecord
  LETTERS = Question::LETTERS
  PERCENTAGES = Question::OPEN_PERCENTAGES

  belongs_to :question, inverse_of: :rubric_levels

  validates :letter, presence: true, inclusion: { in: LETTERS }
  validates :level_index, presence: true, inclusion: { in: 1..LETTERS.size }, if: -> { question&.open? }
  validates :percentage, presence: true, inclusion: { in: PERCENTAGES }, if: -> { question&.open? }
  validates :criteria, presence: true, if: -> { question&.open? }
  validates :examples_evidence, presence: true, if: -> { question&.open? }

  before_validation :sync_defaults

  private

  def sync_defaults
    return unless question&.open?

    self.level_index ||= LETTERS.index(letter) + 1 if letter.present?
    self.percentage ||= PERCENTAGES[level_index - 1] if level_index.present?
  end
end
