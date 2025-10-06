# frozen_string_literal: true

require "bigdecimal"

class BlueprintRule < ApplicationRecord
  ROUNDING_MODES = {
    "nearest" => "Arredondar (padrão)",
    "down" => "Sempre para baixo",
    "up" => "Sempre para cima"
  }.freeze

  belongs_to :blueprint, inverse_of: :rules

  validates :area, presence: true, inclusion: { in: Blueprint.area_keys }
  validates :component, presence: true, uniqueness: { scope: :blueprint_id }
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :max_points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :rounding_mode, presence: true, inclusion: { in: ROUNDING_MODES.keys }
  validate :component_belongs_to_area

  def points_per_unit
    return BigDecimal("0") if quantity.to_i.zero?

    (BigDecimal(max_points.to_s) / BigDecimal(quantity.to_s)).round(4)
  end

  def formatted_points_per_unit
    format("%.4f", points_per_unit)
  end

  def component_name
    blueprint.component_label(area, component)
  end

  def area_name
    blueprint.area_label(area)
  end

  def validation_messages
    [].tap do |messages|
      messages << "#{component_name} deve ter quantidade maior que zero" if quantity.to_i <= 0
      messages << "#{component_name} deve ter pontuação máxima maior ou igual a zero" if BigDecimal(max_points.to_s) < 0
    end
  end

  private

  def component_belongs_to_area
    return if area.blank? || component.blank?

    components = Blueprint.components_for_area(area).keys
    errors.add(:component, :invalid) unless components.include?(component)
  end
end
