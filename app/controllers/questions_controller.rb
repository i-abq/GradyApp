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
      difficulty: params[:difficulty].presence,
      area: params[:area].presence,
      theme: params[:theme].presence
    }

    @questions = filter_questions
    @difficulty_options = difficulty_options
    @area_options = area_options
    @theme_options = theme_options
  end

  private

  def filter_questions
    query = @filters[:q].presence
    difficulty = @filters[:difficulty]
    area = @filters[:area]
    theme = @filters[:theme]

    SAMPLE_QUESTIONS.select do |question|
      matches_query = query.nil? || question[:title].downcase.include?(query.downcase)
      matches_difficulty = difficulty.nil? || question[:difficulty] == difficulty
      matches_area = area.nil? || question[:area] == area
      matches_theme = theme.nil? || question[:theme] == theme

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
end
