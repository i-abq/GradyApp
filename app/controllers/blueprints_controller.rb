class BlueprintsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_blueprint, only: %i[edit update publish retire duplicate]
  before_action :set_form_options, only: %i[new create edit update]

  def index
    @filters = {
      q: params[:q].to_s.strip
    }

    scope = ExamBlueprint.order(year: :desc, modality: :asc, version: :desc)
    if @filters[:q].present?
      query = "%#{@filters[:q]}%"
      scope = scope.where("title ILIKE :q OR modality ILIKE :q", q: query)
    end

    @per_page = 25
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @total_pages = [(scope.count / @per_page.to_f).ceil, 1].max
    @page = @total_pages if @page > @total_pages

    offset = (@page - 1) * @per_page
    @blueprints = scope.offset(offset).limit(@per_page)
  end

  def new
    @blueprint = ExamBlueprint.new(status: "draft", modality: ExamBlueprint::MODALITIES.first, year: Date.current.year, version: 1)
    @blueprint.created_by = current_user
    build_default_structure(@blueprint)
  end

  def create
    @blueprint = ExamBlueprint.new(blueprint_params)
    @blueprint.created_by = current_user

    if @blueprint.save
      redirect_to edit_questions_blueprint_path(@blueprint), notice: "Blueprint criada com sucesso."
    else
      set_form_options
      build_default_structure(@blueprint) if @blueprint.areas.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if @blueprint.published?
      redirect_to questions_blueprints_path, alert: "A blueprint publicada não pode ser editada." and return
    end

    build_default_structure(@blueprint) if @blueprint.areas.empty?
  end

  def update
    if @blueprint.published?
      redirect_to questions_blueprints_path, alert: "A blueprint publicada não pode ser editada." and return
    end

    if @blueprint.update(blueprint_params)
      redirect_to edit_questions_blueprint_path(@blueprint), notice: "Blueprint atualizada com sucesso."
    else
      set_form_options
      render :edit, status: :unprocessable_entity
    end
  end

  def publish
    begin
      @blueprint.publish!
      redirect_to questions_blueprints_path, notice: "Blueprint publicada com sucesso."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to edit_questions_blueprint_path(@blueprint), alert: e.record.errors.full_messages.to_sentence
    end
  end

  def retire
    if @blueprint.published?
      @blueprint.retire!
      redirect_to questions_blueprints_path, notice: "Blueprint retirada com sucesso."
    else
      redirect_to questions_blueprints_path, alert: "Apenas blueprints publicadas podem ser retiradas."
    end
  end

  def duplicate
    dup = @blueprint.duplicate!(current_user)
    redirect_to edit_questions_blueprint_path(dup), notice: "Blueprint duplicada como rascunho."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to edit_questions_blueprint_path(@blueprint), alert: e.record.errors.full_messages.to_sentence
  end

  private

  def set_blueprint
    @blueprint = ExamBlueprint.includes(areas: :components).find(params[:id])
  end

  def set_form_options
    @modality_options = ExamBlueprint::MODALITIES.map { |mod| [mod, mod] }
    @area_options = BlueprintArea::AREAS.map { |code| [code.upcase, code] }
    @component_type_options = BlueprintComponent::COMPONENT_TYPES.map { |type| [type.humanize, type] }
  end

  def blueprint_params
    params.require(:exam_blueprint).permit(
      :modality,
      :year,
      :version,
      :title,
      :notes,
      areas_attributes: [
        :id,
        :area,
        :position,
        :_destroy,
        components_attributes: [
          :id,
          :slug,
          :title,
          :component_type,
          :num_items,
          :maximum_score,
          :position,
          :_destroy
        ]
      ]
    )
  end

  def build_default_structure(blueprint)
    if blueprint.areas.empty?
      area = blueprint.areas.build(area: BlueprintArea::AREAS.first, position: 0)
      area.components.build(component_type: BlueprintComponent::COMPONENT_TYPES.first, title: "", num_items: 0, maximum_score: 0, position: 0)
    else
      blueprint.areas.each do |area|
        area.components.build(component_type: BlueprintComponent::COMPONENT_TYPES.first, title: "", num_items: 0, maximum_score: 0, position: area.components.size) if area.components.empty?
      end
    end
  end
end
