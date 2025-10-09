# frozen_string_literal: true

require "csv"

class QuestionCsvImporter
  Result = Struct.new(:created_count, :failed_rows, :errors, keyword_init: true) do
    def success?
      errors.blank?
    end
  end

  HEADER_MAP = {
    question_type: "question_type",
    area: "area",
    theme: "theme",
    statement: "statement",
    difficulty: "difficulty",
    level: "level",
    year_of_application: "year_of_application",
    source: "source",
    tags: "tags",
    shuffle_alternatives: "shuffle_alternatives",
    maximum_score: "maximum_score"
  }.freeze

  OPTION_LETTERS = Question::LETTERS

  def initialize(file:, author:)
    @file = file
    @author = author
  end

  def call
    rows = CSV.read(@file.path, headers: true)
    created = 0
    failures = []

    rows.each_with_index do |row, index|
      question = build_question_from_row(row)

      if question.save
        created += 1
      else
        failures << {
          row_number: index + 2,
          errors: question.errors.full_messages
        }
      end
    rescue => e
      failures << {
        row_number: index + 2,
        errors: ["Erro inesperado: #{e.message}"]
      }
    end

    Result.new(
      created_count: created,
      failed_rows: failures,
      errors: failures.any? && created.zero? ? ["Nenhuma questão importada"] : []
    )
  end

  def self.sample_csv
    CSV.generate(headers: true) do |csv|
      csv << sample_headers
      csv << sample_mcq_row
      csv << sample_open_row
    end
  end

  def self.sample_headers
    base = HEADER_MAP.values
    base + mcq_headers + open_headers
  end

  def self.sample_mcq_row
    {
      "question_type" => "mcq5_unica",
      "area" => Blueprint.area_keys.first,
      "theme" => Blueprint.components_for_area(Blueprint.area_keys.first).keys.first,
      "statement" => "Exemplo de questão objetiva com texto suficiente.",
      "difficulty" => "easy",
      "level" => "basics",
      "year_of_application" => "2025",
      "source" => "Manual interno",
      "tags" => "exemplo,mcq",
      "shuffle_alternatives" => "true"
    }.merge(sample_mcq_options)
  end

  def self.sample_mcq_options
    data = {}
    OPTION_LETTERS.each_with_index do |letter, index|
      data["option_#{letter.downcase}_text"] = "Alternativa #{letter}"
      data["option_#{letter.downcase}_correct"] = index.zero? ? "true" : "false"
      data["option_#{letter.downcase}_justification"] = "Justificativa #{letter}"
    end
    data
  end

  def self.sample_open_row
    area = Blueprint.area_keys.first
    theme = Blueprint.components_for_area(area).keys.first
    {
      "question_type" => "open5_percent",
      "area" => area,
      "theme" => theme,
      "statement" => "Explique detalhadamente o procedimento solicitado.",
      "maximum_score" => "2.5",
      "tags" => "exemplo,open"
    }.merge(sample_rubric_levels)
  end

  def self.sample_rubric_levels
    data = {}
    OPTION_LETTERS.each_with_index do |letter, index|
      data["rubric_#{letter.downcase}_criteria"] = "Critério nível #{letter}"
      data["rubric_#{letter.downcase}_examples"] = "Evidências nível #{letter}"
    end
    data
  end

  class << self
    private

    def mcq_headers
      OPTION_LETTERS.flat_map do |letter|
        [
          "option_#{letter.downcase}_text",
          "option_#{letter.downcase}_correct",
          "option_#{letter.downcase}_justification"
        ]
      end
    end

    def open_headers
      OPTION_LETTERS.flat_map do |letter|
        [
          "rubric_#{letter.downcase}_criteria",
          "rubric_#{letter.downcase}_examples"
        ]
      end
    end
  end

  private

  def build_question_from_row(row)
    question = Question.new
    question.author = @author
    question.status = :draft

    HEADER_MAP.each do |attribute, header|
      next unless row[header].present?

      value = normalize_field(attribute, row[header])
      question.public_send("#{attribute}=", value)
    end

    question.question_type = row["question_type"].presence || "mcq5_unica"
    question.shuffle_alternatives = ActiveModel::Type::Boolean.new.cast(row["shuffle_alternatives"]) unless row["shuffle_alternatives"].nil?
    question.tags = split_tags(row["tags"]) if row["tags"].present?

    if question.mcq?
      assign_mcq_alternatives(question, row)
    else
      assign_open_rubric(question, row)
    end

    question
  end

  def assign_mcq_alternatives(question, row)
    question.alternatives.destroy_all

    OPTION_LETTERS.each do |letter|
      attrs = {
        letter: letter,
        position: Question::LETTERS.index(letter),
        text: row["option_#{letter.downcase}_text"],
        distractor_justification: row["option_#{letter.downcase}_justification"],
        correct: boolean_from_field(row["option_#{letter.downcase}_correct"])
      }
      question.alternatives.build(attrs)
    end

    question
  end

  def assign_open_rubric(question, row)
    question.maximum_score = row["maximum_score"].to_f if row["maximum_score"].present?
    question.rubric_levels.destroy_all

    OPTION_LETTERS.each_with_index do |letter, index|
      question.rubric_levels.build(
        letter: letter,
        level_index: index + 1,
        percentage: Question::OPEN_PERCENTAGES[index],
        criteria: row["rubric_#{letter.downcase}_criteria"],
        examples_evidence: row["rubric_#{letter.downcase}_examples"]
      )
    end
  end

  def split_tags(value)
    value.to_s.split(/[,;]/).map(&:strip).reject(&:blank?)
  end

  def normalize_field(attribute, value)
    case attribute
    when :year_of_application
      value.to_i if value.present?
    when :shuffle_alternatives
      boolean_from_field(value)
    when :maximum_score
      value.present? ? value.to_f : nil
    else
      value
    end
  end

  def boolean_from_field(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end
end
