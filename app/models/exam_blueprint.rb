require "digest"

class ExamBlueprint < ApplicationRecord
  MODALITIES = %w[P1 P2 P3].freeze
  STATUSES = %w[draft published retired].freeze

  belongs_to :created_by, class_name: "User"

  has_many :areas, class_name: "BlueprintArea", dependent: :destroy, inverse_of: :exam_blueprint
  accepts_nested_attributes_for :areas, allow_destroy: true

  validates :modality, presence: true, inclusion: { in: MODALITIES }
  validates :year, presence: true
  validates :version, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :title, presence: true

  validate :ensure_single_published_per_year
  validate :validate_modality_rules, if: :status_published_or_publishing?

  scope :published, -> { where(status: "published") }

  def publish!
    transaction do
      self.status = "published"
      self.published_on = Time.current
      self.checksum = generate_checksum
      save!
    end
  end

  def retire!
    update!(status: "retired")
  end

  def duplicate!(user)
    dup_blueprint = dup
    dup_blueprint.status = "draft"
    dup_blueprint.version += 1
    dup_blueprint.published_on = nil
    dup_blueprint.checksum = nil
    dup_blueprint.created_by = user

    areas.each do |area|
      dup_area = area.dup
      dup_area.components = area.components.map(&:dup)
      dup_blueprint.areas << dup_area
    end

    dup_blueprint.save!
    dup_blueprint
  end

  def published?
    status == "published"
  end

  private

  def ensure_single_published_per_year
    return unless status == "published"

    conflict = ExamBlueprint.where(modality: modality, year: year, status: "published")
    conflict = conflict.where.not(id: id) if persisted?
    errors.add(:base, "Já existe uma blueprint publicada para esta modalidade e ano") if conflict.exists?
  end

  def validate_modality_rules
    case modality
    when "P2"
      validate_p2_totals
    end
  end

  def validate_p2_totals
    area_totals = areas.each_with_object(Hash.new { |hash, key| hash[key] = { items: 0, score: BigDecimal("0") } }) do |area, acc|
      area.components.each do |component|
        acc[area.area][:items] += component.num_items.to_i
        acc[area.area][:score] += BigDecimal(component.maximum_score.to_s)
      end
    end

    area_totals.each do |area_key, totals|
      unless totals[:items] == 100
        errors.add(:base, "Área #{area_key}: quantidade de itens precisa somar 100 (atual: #{totals[:items]})")
      end

      unless totals[:score] == BigDecimal("10.0")
        errors.add(:base, "Área #{area_key}: pontuação máxima precisa somar 10.0 (atual: #{totals[:score]})")
      end
    end
  end

  def generate_checksum
    payload = {
      modality: modality,
      year: year,
      version: version,
      areas: areas.map do |area|
        {
          area: area.area,
          position: area.position,
          components: area.components.map do |component|
            component.attributes.slice("slug", "title", "component_type", "num_items", "maximum_score", "json_rules", "position")
          end
        }
      end
    }

    Digest::SHA256.hexdigest(payload.to_json)
  end

  def status_published_or_publishing?
    status == "published" || (status_change_to_be_saved == ["draft", "published"])
  end
end
