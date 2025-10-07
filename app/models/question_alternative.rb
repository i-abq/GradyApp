# frozen_string_literal: true

class QuestionAlternative < ApplicationRecord
  LETTERS = Question::LETTERS

  belongs_to :question, inverse_of: :alternatives

  validates :letter, presence: true, inclusion: { in: LETTERS }
  validates :text, presence: true, if: -> { question&.mcq? }
  validates :position, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :only_one_correct_per_question, if: -> { question&.mcq? }

  before_validation :sync_position

  scope :ordered, -> { order(:position) }

  private

  def sync_position
    self.position ||= LETTERS.index(letter)&.itself || 0
  end

  def only_one_correct_per_question
    return unless question && correct?

    duplicates = question.alternatives.reject { |alt| alt.equal?(self) }.select(&:correct?)
    errors.add(:correct, "já existe outra alternativa correta") if duplicates.any?
  end
end
