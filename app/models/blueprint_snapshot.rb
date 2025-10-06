# frozen_string_literal: true

class BlueprintSnapshot < ApplicationRecord
  belongs_to :blueprint, inverse_of: :snapshots
  belongs_to :creator, class_name: "User", foreign_key: "created_by_id"

  validates :payload, presence: true
  validates :checksum, presence: true, uniqueness: true
end
