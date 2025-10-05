class BlueprintArea < ApplicationRecord
  AREAS = %w[mn rd rt].freeze

  belongs_to :exam_blueprint, inverse_of: :areas
  has_many :components, class_name: "BlueprintComponent", dependent: :destroy, inverse_of: :blueprint_area

  accepts_nested_attributes_for :components, allow_destroy: true

  validates :area, presence: true, inclusion: { in: AREAS }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(:position, :id) }
end
