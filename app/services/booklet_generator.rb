# frozen_string_literal: true

require "digest"

class BookletGenerator
  class GenerationError < StandardError; end

  attr_reader :blueprint, :area_key, :actor

  def initialize(blueprint:, area_key:, actor:)
    @blueprint = blueprint
    @area_key = area_key
    @actor = actor
  end

  def call
    ensure_published_blueprint!

    blueprint_snapshot = blueprint.latest_snapshot
    raise GenerationError, "Blueprint não possui snapshot publicado" if blueprint_snapshot.nil?

    allocation_rules = fetch_allocation_rules(blueprint_snapshot.payload)
    raise GenerationError, "Blueprint não possui configuração para a área #{area_key}" if allocation_rules.blank?

    selection, failures = select_questions(allocation_rules)
    raise GenerationError, build_failures_message(failures) if failures.any?

    payload = build_booklet_payload(blueprint_snapshot, allocation_rules, selection)
    checksum = Digest::SHA256.hexdigest(payload.to_json)

    booklet_snapshot = BookletSnapshot.create!(
      blueprint: blueprint,
      blueprint_snapshot: blueprint_snapshot,
      area: area_key,
      payload: payload,
      checksum: checksum,
      generated_by: actor
    )

    booklet_snapshot
  end

  private

  def ensure_published_blueprint!
    raise GenerationError, "Blueprint precisa estar publicado" unless blueprint.status_published?
  end

  def fetch_allocation_rules(snapshot_payload)
    allocation = snapshot_payload.fetch("allocation", {})
    allocation[area_key] || allocation[area_key.to_sym]
  end

  def select_questions(allocation_rules)
    restrictions_map = blueprint.restrictions.each_with_object({}) do |restriction, acc|
      next unless restriction.area == area_key

      acc[restriction.component] = restriction
    end

    selection = []
    failures = []

    allocation_rules.each do |rule|
      component_key = rule[:component] || rule["component"]
      quantity = (rule[:quantity] || rule["quantity"]).to_i
      next if quantity.zero?

      points_per_unit = rule[:rounded_points_per_unit] || rule["rounded_points_per_unit"] || rule[:points_per_unit] || rule["points_per_unit"]
      questions_scope = Question.where(status: Question.statuses[:approved], area: area_key, theme: component_key).order(updated_at: :desc)
      restriction = restrictions_map[component_key]
      questions = apply_restrictions(questions_scope.to_a, restriction).first(quantity)

      if questions.size < quantity
        failures << {
          component: component_key,
          required: quantity,
          available: questions.size
        }
        next
      end

      selection << {
        component: component_key,
        label: rule[:label] || rule["label"],
        required: quantity,
        points_per_unit: points_per_unit.to_f,
        questions: questions.map do |question|
          {
            question_id: question.id,
            area: question.area,
            component: question.theme,
            points_per_unit: points_per_unit.to_f,
            anchor: question.anchored?,
            voidable: question.voidable?,
            official_answer: question.official_answer
          }
        end
      }
    end

    [selection, failures]
  end

  def build_failures_message(failures)
    failures.map do |failure|
      "Sem itens suficientes para #{failure[:component]} (necessário #{failure[:required]}, disponível #{failure[:available]})"
    end.join("; ")
  end

  def build_booklet_payload(blueprint_snapshot, allocation_rules, selection)
    total_questions = selection.sum { |entry| entry[:questions].size }
    total_points = selection.sum do |entry|
      entry[:questions].size * entry[:points_per_unit].to_f
    end

    {
      schema_version: "booklet/v1",
      blueprint_snapshot_id: blueprint_snapshot.id,
      blueprint: {
        id: blueprint.id,
        year: blueprint.year,
        modality: blueprint.modality,
        version: blueprint.version
      },
      area: {
        key: area_key,
        label: blueprint.area_label(area_key)
      },
      allocation_rules: allocation_rules,
      selection: selection,
      totals: {
        questions_count: total_questions,
        total_points: total_points
      }
    }
  end

  def apply_restrictions(questions, restriction)
    return questions if restriction.nil?

    filtered = questions

    include_tags = restriction.include_tags_list
    if include_tags.any?
      filtered = filtered.select do |question|
        (include_tags - Array(question.tags)).empty?
      end
    end

    exclude_tags = restriction.exclude_tags_list
    if exclude_tags.any?
      filtered = filtered.reject do |question|
        (exclude_tags & Array(question.tags)).any?
      end
    end

    filtered
  end
end
