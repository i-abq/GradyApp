class QuestionsController < ApplicationController
  before_action :authenticate_user!

  SAMPLE_QUESTIONS = [
    { id: 1023, title: "Composição de funções lineares", difficulty: "easy", area: "Matemática", theme: "Funções" },
    { id: 1048, title: "Leis de Newton aplicadas ao movimento circular", difficulty: "medium", area: "Física", theme: "Dinâmica" },
    { id: 1120, title: "Interpretação de charges com foco em argumentos implícitos", difficulty: "hard", area: "Linguagens", theme: "Compreensão textual" },
    { id: 1185, title: "Estrutura de DNA e síntese proteica", difficulty: "medium", area: "Biologia", theme: "Genética" },
    { id: 1254, title: "Análise de gráficos de calor urbano", difficulty: "easy", area: "Geografia", theme: "Climatologia" },
    { id: 1331, title: "Processos de formação do Império Romano", difficulty: "hard", area: "História", theme: "Antiguidade" }
  ].freeze

  def index
    @filters = {
      q: params[:q].to_s.strip,
      difficulty: Array(params[:difficulty]).flatten.map(&:presence).compact,
      area: Array(params[:area]).flatten.map(&:presence).compact,
      theme: Array(params[:theme]).flatten.map(&:presence).compact
    }

    @questions = filter_questions
    @difficulty_options = difficulty_options
    @area_options = area_options
    @theme_options = theme_options
    @difficulty_counts = difficulty_counts
    @area_counts = area_counts
    @theme_counts = theme_counts
  end

  private

  def filter_questions
    query = @filters[:q].presence
    selected_difficulties = Array(@filters[:difficulty])
    selected_areas = Array(@filters[:area])
    selected_themes = Array(@filters[:theme])

    SAMPLE_QUESTIONS.select do |question|
      matches_query = query.nil? || question[:title].downcase.include?(query.downcase)
      matches_difficulty = selected_difficulties.blank? || selected_difficulties.include?(question[:difficulty])
      matches_area = selected_areas.blank? || selected_areas.include?(question[:area])
      matches_theme = selected_themes.blank? || selected_themes.include?(question[:theme])

      matches_query && matches_difficulty && matches_area && matches_theme
    end
  end

  def difficulty_options
    QuestionsHelper::DIFFICULTY_LABELS.map { |value, label| [label, value] }
  end

  def area_options
    SAMPLE_QUESTIONS.map { |question| question[:area] }.uniq.sort.map { |area| [area, area] }
  end

  def theme_options
    SAMPLE_QUESTIONS.map { |question| question[:theme] }.uniq.sort.map { |theme| [theme, theme] }
  end

  def difficulty_counts
    query = @filters[:q].presence&.downcase
    areas = Array(@filters[:area])
    themes = Array(@filters[:theme])

    counts = SAMPLE_QUESTIONS.each_with_object(Hash.new(0)) do |question, acc|
      next if query.present? && !question[:title].downcase.include?(query)
      next if areas.present? && !areas.include?(question[:area])
      next if themes.present? && !themes.include?(question[:theme])

      acc[question[:difficulty]] += 1
    end

    QuestionsHelper::DIFFICULTY_LABELS.keys.each_with_object({}) do |difficulty, acc|
      acc[difficulty] = counts[difficulty] || 0
    end
  end

  def area_counts
    query = @filters[:q].presence&.downcase
    difficulties = Array(@filters[:difficulty])
    themes = Array(@filters[:theme])

    counts = SAMPLE_QUESTIONS.each_with_object(Hash.new(0)) do |question, acc|
      next if query.present? && !question[:title].downcase.include?(query)
      next if difficulties.present? && !difficulties.include?(question[:difficulty])
      next if themes.present? && !themes.include?(question[:theme])

      acc[question[:area]] += 1
    end

    area_values = area_options.map { |_, value| value }
    area_values.each_with_object({}) do |area, acc|
      acc[area] = counts[area] || 0
    end
  end

  def theme_counts
    query = @filters[:q].presence&.downcase
    difficulties = Array(@filters[:difficulty])
    areas = Array(@filters[:area])

    counts = SAMPLE_QUESTIONS.each_with_object(Hash.new(0)) do |question, acc|
      next if query.present? && !question[:title].downcase.include?(query)
      next if difficulties.present? && !difficulties.include?(question[:difficulty])
      next if areas.present? && !areas.include?(question[:area])

      acc[question[:theme]] += 1
    end

    theme_values = theme_options.map { |_, value| value }
    theme_values.each_with_object({}) do |theme, acc|
      acc[theme] = counts[theme] || 0
    end
  end
end
