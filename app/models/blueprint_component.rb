class BlueprintComponent < ApplicationRecord
  COMPONENT_TYPES = %w[mcq_theme discursive_part practical_station].freeze

  belongs_to :blueprint_area, inverse_of: :components

  validates :title, presence: true
  validates :component_type, presence: true, inclusion: { in: COMPONENT_TYPES }
  validates :num_items, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :maximum_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(:position, :id) }

  def points_per_item
    return 0 if num_items.to_i.zero?

    maximum_score.to_f / num_items.to_i
  end
end
