# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: [:edit, :update, :submit_review, :approve]
  before_action :prepare_collections, only: [:index, :new, :edit, :import]

  PER_PAGE = 25

  def index
    @filters = {
      q: params[:q].to_s.strip,
      area: Array(params[:area]).reject(&:blank?),
      theme: Array(params[:theme]).reject(&:blank?),
      status: Array(params[:status]).reject(&:blank?)
    }

    scope = apply_filters(Question.includes(:author).ordered)

    @total_count = scope.count
    @total_pages = [(@total_count / PER_PAGE.to_f).ceil, 1].max
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @page = @total_pages if @page > @total_pages

    @questions = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def new
    @question = build_question
  end

  def import_template
    send_data QuestionCsvImporter.sample_csv,
              filename: "modelo_importacao_questoes.csv",
              type: "text/csv"
  end

  def create
    @question = current_user.authored_questions.build(question_params)
    assign_nested_defaults(@question)

    if @question.save
      handle_post_save(@question)
    else
      prepare_collections
      @current_step = params[:current_step].presence || 1
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @current_step = params[:current_step].presence || 1
    assign_nested_defaults(@question)
  end

  def update
    assign_nested_defaults(@question)

    if @question.update(question_params)
      handle_post_save(@question)
    else
      prepare_collections
      @current_step = params[:current_step].presence || 1
      render :edit, status: :unprocessable_entity
    end
  end

  def import
    return unless request.post?

    if params[:file].blank?
      flash.now[:alert] = "Selecione um arquivo CSV."
      render :import, status: :unprocessable_entity
      return
    end

    importer = QuestionCsvImporter.new(file: params[:file], author: current_user)
    result = importer.call

    if result.failed_rows.empty?
      redirect_to questions_path, notice: "#{result.created_count} questões importadas com sucesso."
    else
      @created_count = result.created_count
      @failed_rows = result.failed_rows
      flash.now[:alert] = "Algumas linhas não foram importadas."
      render :import, status: :unprocessable_entity
    end
  end

  def submit_review
    if @question.update(status: :review)
      redirect_to questions_path, notice: "Questão enviada para revisão."
    else
      prepare_collections
      flash.now[:alert] = "Não foi possível enviar para revisão."
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    unless @question.status_review?
      redirect_to edit_question_path(@question, current_step: 4), alert: "A aprovação requer que a questão esteja em revisão." and return
    end

    # Re-validate the item before approval
    if @question.valid?
      @question.update!(status: :approved, approver: current_user, approved_on: Time.current)
      redirect_to questions_path, notice: "Questão aprovada."
    else
      prepare_collections
      @current_step = 4
      flash.now[:alert] = "Corrija os erros antes de aprovar."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_question
    @question = Question.includes(:alternatives, :rubric_levels).find(params[:id])
  end

  def build_question
    Question.new(question_type: params[:question_type].presence || "mcq5_unica").tap do |question|
      question.omr_letter_map = nil
      assign_nested_defaults(question)
      default_area = Blueprint.area_keys.first
      question.area ||= default_area
      question.theme ||= Blueprint.components_for_area(default_area).keys.first
    end
  end

  def assign_nested_defaults(question)
    if question.mcq?
      ensure_mcq_defaults(question)
    else
      ensure_open_defaults(question)
    end
  end

  def ensure_mcq_defaults(question)
    missing_letters = Question::LETTERS - question.alternatives.map(&:letter)
    missing_letters.each_with_index do |letter, index|
      question.alternatives.build(letter:, position: index, text: "", correct: false)
    end

    question.alternatives.each do |alternative|
      alternative.position = Question::LETTERS.index(alternative.letter)
    end
  end

  def ensure_open_defaults(question)
    question.alternatives.each { |alt| alt.mark_for_destruction }
    question.percent_mapping = question.send(:default_percent_mapping) if question.percent_mapping.blank?

    existing_letters = question.rubric_levels.map(&:letter)
    (Question::LETTERS - existing_letters).each_with_index do |letter, index|
      percentage = Question::OPEN_PERCENTAGES[index]
      question.rubric_levels.build(
        letter:,
        level_index: index + 1,
        percentage:,
        criteria: "",
        examples_evidence: ""
      )
    end

    question.maximum_score ||= 1.0
  end

  def question_params
    permitted = params.require(:question).permit(
      :question_type,
      :area,
      :theme,
      :year_of_application,
      :difficulty,
      :level,
      :source,
      :usage_rights,
      :author_comment,
      :statement,
      :shuffle_alternatives,
      :maximum_score,
      :voidable,
      :anchored,
      :anchor_set_id,
      :tags_text,
      tags: [],
      omr_letter_map: {},
      percent_mapping: {},
      alternatives_attributes: [:id, :letter, :text, :correct, :distractor_justification, :position, :_destroy],
      rubric_levels_attributes: [:id, :letter, :level_index, :percentage, :criteria, :examples_evidence, :_destroy]
    )

    tags_text = permitted.delete(:tags_text)
    if tags_text.present?
      permitted[:tags] = tags_text.split(',').map(&:strip).reject(&:blank?)
    elsif !permitted.key?(:tags)
      permitted[:tags] = []
    end

    if permitted[:omr_letter_map].respond_to?(:to_unsafe_h)
      permitted[:omr_letter_map] = permitted[:omr_letter_map].to_unsafe_h
    elsif permitted[:omr_letter_map].respond_to?(:to_h)
      permitted[:omr_letter_map] = permitted[:omr_letter_map].to_h
    end

    if permitted[:percent_mapping].respond_to?(:to_unsafe_h)
      permitted[:percent_mapping] = permitted[:percent_mapping].to_unsafe_h
    elsif permitted[:percent_mapping].respond_to?(:to_h)
      permitted[:percent_mapping] = permitted[:percent_mapping].to_h
    end

    permitted
  end

  def apply_filters(scope)
    filtered = scope
    filtered = filtered.where("LOWER(statement) LIKE :query", query: "%#{@filters[:q].downcase}%") if @filters[:q].present?
    filtered = filtered.where(area: @filters[:area]) if @filters[:area].present?
    filtered = filtered.where(theme: @filters[:theme]) if @filters[:theme].present?
    filtered = filtered.where(status: @filters[:status]) if @filters[:status].present?
    filtered
  end

  def handle_post_save(question)
    case params[:commit]
    when "review"
      question.update(status: :review)
      redirect_to questions_path, notice: "Questão enviada para revisão."
    else
      question.update(status: :draft)
      redirect_to edit_question_path(question), notice: "Questão salva como rascunho."
    end
  end

  def prepare_collections
    @area_options = Blueprint::AREAS.map { |key, config| [config[:label], key] }
    if action_name == "index"
      @theme_options = Blueprint::AREAS.flat_map do |area_key, config|
        config[:components].map do |component_key, component|
          ["#{config[:label]} · #{component[:label]}", component_key]
        end
      end
    else
      selected_area = params.dig(:question, :area) || @question&.area || @area_options.first&.last
      @theme_options = Blueprint.components_for_area(selected_area).map { |key, component| [component[:label], key] }
    end
    @difficulty_options = Question::DIFFICULTIES.map { |value| [QuestionsHelper::DIFFICULTY_LABELS[value], value] }
    @level_options = Question::LEVELS.map { |value| [value.titleize, value] }
    @status_options = Question::STATUSES.map { |value, label| [label, value] }

    return unless action_name == "index"

    base_scope = Question.all
    @area_counts = base_scope.group(:area).count.transform_keys(&:to_s)
    @theme_counts = base_scope.group(:theme).count.transform_keys(&:to_s)
    @status_counts = base_scope.group(:status).count.transform_keys(&:to_s)
  end
end
