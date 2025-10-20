# frozen_string_literal: true

class BookletSnapshot < ApplicationRecord
  belongs_to :blueprint
  belongs_to :blueprint_snapshot
  belongs_to :generator, class_name: "User", foreign_key: :generated_by_id

  validates :area, presence: true
  validates :payload, presence: true
  validates :checksum, presence: true, uniqueness: true
end
