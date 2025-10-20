# frozen_string_literal: true

class BlueprintScoringPolicy < ApplicationRecord
  BLANK_BEHAVIORS = %w[zero equals_wrong custom].freeze
  NORMALIZATIONS = %w[none per_area global].freeze

  belongs_to :blueprint

  validates :wrong_penalty, numericality: true
  validates :blank_behavior, inclusion: { in: BLANK_BEHAVIORS }
  validates :normalization, inclusion: { in: NORMALIZATIONS }
  validates :blank_points, numericality: true, allow_nil: true

  def blank_points_value
    blank_behavior == "custom" ? blank_points.to_f : nil
  end
end
