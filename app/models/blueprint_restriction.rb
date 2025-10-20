# frozen_string_literal: true

class BlueprintRestriction < ApplicationRecord
  belongs_to :blueprint

  validates :area, presence: true, inclusion: { in: ->(_) { Blueprint.area_keys } }
  validates :component, presence: true
  validate :component_matches_area

  def include_tags_list
    Array(include_tags)
  end

  def exclude_tags_list
    Array(exclude_tags)
  end

  private

  def component_matches_area
    return if area.blank? || component.blank?

    unless Blueprint.components_for_area(area).key?(component)
      errors.add(:component, :invalid)
    end
  end
end
