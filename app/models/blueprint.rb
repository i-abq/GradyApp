# frozen_string_literal: true

require "digest"
require "bigdecimal"

class Blueprint < ApplicationRecord
  DEFAULT_TARGET_QUESTIONS = 100
  DEFAULT_TARGET_POINTS = BigDecimal("10.0")

  MODALITIES = {
    "p1" => "P1 (Discursiva)",
    "p2" => "P2 (Objetiva)",
    "p3" => "P3 (Prática/Oral)"
  }.freeze

  STATUSES = {
    "draft" => "Rascunho",
    "published" => "Publicado"
  }.freeze

  AREAS = {
    "medicina_nuclear" => {
      label: "Medicina Nuclear",
      components: {
        "fisica_das_radiacoes_ionizantes" => { label: "Física das radiações ionizantes", default_quantity: 15, default_max_points: BigDecimal("1.0") },
        "processamento_de_sinais" => { label: "Processamento de sinais", default_quantity: 15, default_max_points: BigDecimal("2.0") },
        "instrumentacao" => { label: "Instrumentação", default_quantity: 15, default_max_points: BigDecimal("2.0") },
        "dosimetria_interna" => { label: "Dosimetria interna", default_quantity: 15, default_max_points: BigDecimal("1.0") },
        "garantia_da_qualidade" => { label: "Garantia da qualidade", default_quantity: 15, default_max_points: BigDecimal("1.0") },
        "seguranca_radiologica" => { label: "Segurança radiológica", default_quantity: 15, default_max_points: BigDecimal("2.0") },
        "conhecimentos_em_medicina" => { label: "Conhecimentos em medicina", default_quantity: 10, default_max_points: BigDecimal("1.0") }
      }
    },
    "radiodiagnostico" => {
      label: "Radiodiagnóstico",
      components: {
        "fisica_radiacoes_e_fundamentos" => { label: "Física das radiações ionizantes e fundamentos de radiologia", default_quantity: 15, default_max_points: BigDecimal("1.5") },
        "detectores_e_processamento_digital" => { label: "Detectores de imagens e processamento digital", default_quantity: 15, default_max_points: BigDecimal("1.5") },
        "radiologia_conv_digital_mamografia" => { label: "Radiologia convencional/digital/mamografia", default_quantity: 15, default_max_points: BigDecimal("1.5") },
        "fluoroscopia_e_intervencionista" => { label: "Fluoroscopia e radiologia intervencionista", default_quantity: 15, default_max_points: BigDecimal("1.5") },
        "tomografia_computadorizada" => { label: "Tomografia computadorizada", default_quantity: 15, default_max_points: BigDecimal("1.5") },
        "rm_e_ultrassom" => { label: "Ressonância magnética e ultrassom", default_quantity: 10, default_max_points: BigDecimal("1.0") },
        "garantia_qualidade_protecao" => { label: "Garantia da qualidade e proteção radiológica", default_quantity: 15, default_max_points: BigDecimal("1.5") }
      }
    },
    "radioterapia" => {
      label: "Radioterapia",
      components: {
        "fisica_das_radiacoes_ionizantes" => { label: "Física das radiações ionizantes", default_quantity: 15, default_max_points: BigDecimal("1.0") },
        "dosimetria" => { label: "Dosimetria", default_quantity: 15, default_max_points: BigDecimal("2.0") },
        "teleterapia" => { label: "Teleterapia", default_quantity: 15, default_max_points: BigDecimal("2.0") },
        "braquiterapia" => { label: "Braquiterapia", default_quantity: 15, default_max_points: BigDecimal("1.0") },
        "garantia_da_qualidade" => { label: "Garantia da qualidade", default_quantity: 15, default_max_points: BigDecimal("2.0") },
        "seguranca_radiologica" => { label: "Segurança radiológica", default_quantity: 15, default_max_points: BigDecimal("1.0") },
        "conhecimentos_em_medicina" => { label: "Conhecimentos em medicina", default_quantity: 10, default_max_points: BigDecimal("1.0") }
      }
    }
  }.freeze

  belongs_to :creator, class_name: "User", foreign_key: "created_by_id"

  has_many :rules, class_name: "BlueprintRule", dependent: :destroy, inverse_of: :blueprint
  has_many :snapshots, class_name: "BlueprintSnapshot", dependent: :destroy, inverse_of: :blueprint

  accepts_nested_attributes_for :rules

  enum :status, STATUSES.keys.index_by(&:to_sym), prefix: true
  enum :modality, MODALITIES.keys.index_by(&:to_sym), suffix: true

  validates :year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 2000 }
  validates :modality, presence: true, inclusion: { in: MODALITIES.keys }
  validates :name, presence: true, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: STATUSES.keys }
  validates :target_questions_per_area, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :target_points_per_area, presence: true, numericality: { greater_than: 0 }

  before_validation :ensure_defaults
  after_initialize :ensure_default_rules, if: :new_record?

  scope :ordered, -> { order(created_at: :desc) }

  def self.area_keys
    AREAS.keys
  end

  def self.components_for_area(area_key)
    AREAS.fetch(area_key, {})[:components] || {}
  end

  def self.build_with_defaults(attributes = {})
    new({ modality: "p2", target_questions_per_area: DEFAULT_TARGET_QUESTIONS, target_points_per_area: DEFAULT_TARGET_POINTS }.merge(attributes))
  end

  def ensure_default_rules
    assign_default_rules! if rules.empty?
  end

  def assign_default_rules!(defaults = default_rule_set)
    defaults.each do |area_key, components|
      components.each do |component_key, config|
        next if rules.any? { |rule| rule.area == area_key && rule.component == component_key }

        rules.build(
          area: area_key,
          component: component_key,
          quantity: config[:quantity],
          max_points: config[:max_points],
          rounding_mode: config[:rounding_mode] || "nearest"
        )
      end
    end
  end

  def default_rule_set
    AREAS.transform_values do |area|
      area[:components].transform_values do |component|
        {
          quantity: component[:default_quantity],
          max_points: component[:default_max_points],
          rounding_mode: "nearest"
        }
      end
    end
  end

  def area_label(area_key)
    AREAS.dig(area_key, :label) || area_key.to_s.humanize
  end

  def component_label(area_key, component_key)
    AREAS.dig(area_key, :components, component_key, :label) || component_key.to_s.humanize
  end

  def area_totals
    totals = {}

    AREAS.each_key do |area_key|
      area_rules = rules.select { |rule| rule.area == area_key }
      total_quantity = area_rules.sum { |rule| rule.quantity.to_i }
      total_points = area_rules.sum { |rule| BigDecimal(rule.max_points.to_s) }
      target_points = BigDecimal(target_points_per_area.to_s)
      totals[area_key] = {
        area: area_key,
        label: area_label(area_key),
        total_quantity: total_quantity,
        total_points: total_points,
        delta_quantity: target_questions_per_area - total_quantity,
        delta_points: (target_points - total_points).round(4),
        valid_quantity: total_quantity == target_questions_per_area,
        valid_points: (target_points - total_points).abs <= BigDecimal("0.0001")
      }
    end

    totals
  end

  def publication_issues
    issues = []

    rules.each do |rule|
      issues.concat(rule.validation_messages)
    end

    area_totals.each_value do |totals|
      unless totals[:valid_quantity]
        issues << "#{totals[:label]} precisa totalizar #{target_questions_per_area} questões"
      end

      unless totals[:valid_points]
        issues << "#{totals[:label]} precisa totalizar #{format('%.4f', target_points_per_area)} pontos"
      end
    end

    issues.uniq
  end

  def ready_for_publication?
    publication_issues.empty?
  end

  def publish!(publisher)
    raise ArgumentError, "Blueprint já publicado" if status_published?

    issues = publication_issues
    raise PublicationError, issues unless issues.empty?

    transaction do
      update!(status: :published, published_at: Time.current)
      payload = snapshot_payload
      snapshots.create!(payload:, checksum: Digest::SHA256.hexdigest(payload.to_json), created_by: publisher)
    end
  end

  def snapshot_payload
    grouped_rules = rules
      .sort_by { |rule| [rule.area, rule.component] }
      .group_by(&:area)

    {
      blueprint: {
        id: id,
        year: year,
        modality: modality,
        name: name,
        version: version,
        published_at: published_at&.iso8601
      },
      targets: {
        questions_per_area: target_questions_per_area,
        points_per_area: target_points_per_area.to_f
      },
      areas: grouped_rules.transform_values do |area_rules|
        area_rules.map do |rule|
          {
            component: rule.component,
            quantity: rule.quantity,
            max_points: rule.max_points.to_f,
            points_per_unit: rule.points_per_unit.to_f,
            rounding_mode: rule.rounding_mode
          }
        end
      end,
      totals: area_totals.transform_values do |totals|
        totals.merge(
          total_points: totals[:total_points].to_f,
          delta_points: totals[:delta_points].to_f
        )
      end
    }
  end

  def latest_snapshot
    snapshots.order(created_at: :desc).first
  end

  class PublicationError < StandardError
    attr_reader :issues

    def initialize(issues)
      super("Blueprint não pode ser publicado")
      @issues = issues
    end
  end

  private

  def ensure_defaults
    self.modality ||= "p2"
    self.status ||= "draft"
    self.target_questions_per_area ||= DEFAULT_TARGET_QUESTIONS
    self.target_points_per_area ||= DEFAULT_TARGET_POINTS
    self.version ||= "1.0.0"
  end
end
