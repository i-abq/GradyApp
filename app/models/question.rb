# frozen_string_literal: true

require "securerandom"

class Question < ApplicationRecord
  QUESTION_TYPES = {
    "mcq5_unica" => "Objetiva (5 alternativas)",
    "open5_percent" => "Aberta (rubrica 5 níveis)"
  }.freeze

  STATUSES = {
    "draft" => "Rascunho",
    "review" => "Em revisão",
    "approved" => "Aprovada",
    "retired" => "Retirada"
  }.freeze

  DIFFICULTIES = %w[easy medium hard].freeze
  LEVELS = %w[basics intermediate advanced].freeze
  LETTERS = %w[A B C D E].freeze
  OPEN_PERCENTAGES = [0, 25, 50, 75, 100].freeze

  belongs_to :author, class_name: "User"
  belongs_to :reviewer, class_name: "User", optional: true
  belongs_to :approver, class_name: "User", optional: true

  has_many :alternatives, -> { order(:position) }, class_name: "QuestionAlternative", dependent: :destroy, inverse_of: :question
  has_many :rubric_levels, -> { order(:level_index) }, class_name: "QuestionRubricLevel", dependent: :destroy, inverse_of: :question

  accepts_nested_attributes_for :alternatives, allow_destroy: true
  accepts_nested_attributes_for :rubric_levels, allow_destroy: true

  enum :status, STATUSES.keys.index_with { |key| key }, prefix: true
  enum :question_type, QUESTION_TYPES.keys.index_with { |key| key }, suffix: true

  validates :question_type, presence: true, inclusion: { in: QUESTION_TYPES.keys }
  validates :status, presence: true, inclusion: { in: STATUSES.keys }
  validates :area, presence: true, inclusion: { in: ->(_) { Blueprint.area_keys } }
  validates :theme, presence: true
  validates :theme, inclusion: { in: ->(record) { Blueprint.components_for_area(record.area).keys } }, if: -> { area.present? }
  validates :statement, presence: true, length: { minimum: 15 }
  validates :usage_rights, presence: true, unless: -> { usage_rights.blank? }
  validates :omr_letter_map, presence: true
  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_blank: true
  validates :level, inclusion: { in: LEVELS }, allow_blank: true
  validates :maximum_score, numericality: { greater_than: 0 }, allow_nil: true

  validate :validate_omr_letter_map
  validate :validate_mcq_requirements, if: :mcq?
  validate :validate_open_requirements, if: :open?

  before_validation :ensure_defaults
  before_validation :ensure_collections_initialized

  scope :ordered, -> { order(created_at: :desc) }

  def mcq?
    question_type == "mcq5_unica"
  end

  def open?
    question_type == "open5_percent"
  end

  def official_answer
    return nil unless mcq?

    alternatives.detect(&:correct)&.letter
  end

  def percent_mapping_hash
    return percent_mapping if percent_mapping.present? && percent_mapping.keys.size == 5

    default_percent_mapping
  end

  def status_label
    STATUSES[status] || status.to_s.humanize
  end

  def question_type_label
    QUESTION_TYPES[question_type] || question_type.to_s.humanize
  end

  def area_label
    Blueprint::AREAS.dig(area, :label) || area.to_s.humanize
  end

  def theme_label
    Blueprint::AREAS.dig(area, :components, theme, :label) || theme.to_s.humanize
  end

  private

  def ensure_defaults
    self.item_id ||= SecureRandom.uuid
    self.status ||= "draft"
    self.version ||= 1
    self.shuffle_alternatives = true if shuffle_alternatives.nil?
    self.percent_mapping = default_percent_mapping if percent_mapping.blank? && open?
    self.omr_letter_map = default_omr_map if omr_letter_map.blank?
  end

  def ensure_collections_initialized
    self.tags ||= []
  end

  def default_omr_map
    LETTERS.each_with_index.each_with_object({}) do |(letter, index), acc|
      acc[letter] = (index + 1).to_s
    end
  end

  def default_percent_mapping
    return {} unless open?

    LETTERS.each_with_index.each_with_object({}) do |(_letter, index), acc|
      acc[(index + 1).to_s] = OPEN_PERCENTAGES[index]
    end
  end

  def validate_omr_letter_map
    mapping = case omr_letter_map
              when Hash
                omr_letter_map.transform_keys(&:to_s)
              when Array
                omr_letter_map.to_h.transform_keys(&:to_s)
              else
                {}
              end

    missing_letters = LETTERS - mapping.keys
    errors.add(:omr_letter_map, "precisa conter as letras #{LETTERS.join(', ')}") if missing_letters.present?
  end

  def validate_mcq_requirements
    active_alternatives = alternatives.reject(&:marked_for_destruction?)

    if active_alternatives.size != LETTERS.size
      errors.add(:alternatives, "devem conter exatamente #{LETTERS.size} alternativas")
    end

    letters = active_alternatives.map(&:letter)
    if letters.sort != LETTERS
      errors.add(:alternatives, "precisam usar as letras #{LETTERS.join(', ')}")
    end

    corrects = active_alternatives.select(&:correct)
    if corrects.size != 1
      errors.add(:alternatives, "devem ter exatamente uma alternativa correta")
    end

    active_alternatives.each do |alternative|
      next if alternative.correct?

      next if alternative.distractor_justification.present?
    end
  end

  def validate_open_requirements
    active_levels = rubric_levels.reject(&:marked_for_destruction?)

    if active_levels.size != LETTERS.size
      errors.add(:rubric_levels, "devem conter exatamente #{LETTERS.size} níveis")
      return
    end

    letters = active_levels.map(&:letter)
    unless letters.sort == LETTERS
      errors.add(:rubric_levels, "precisam usar as letras #{LETTERS.join(', ')}")
    end

    percentages = active_levels.map(&:percentage).sort
    unless percentages == OPEN_PERCENTAGES
      errors.add(:rubric_levels, "precisam ter percentuais #{OPEN_PERCENTAGES.join(', ')}")
    end

    active_levels.each do |level|
      if level.criteria.blank?
        errors.add(:rubric_levels, "#{level.letter}: precisa de critério")
      end
    end

    if maximum_score.nil? || maximum_score <= 0
      errors.add(:maximum_score, "precisa ser maior que zero")
    end
  end
end
