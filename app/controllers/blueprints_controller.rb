# frozen_string_literal: true

class BlueprintsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_blueprint, only: [:edit, :update, :publish]
  before_action :set_current_step, only: [:new, :create, :edit, :update]

  PER_PAGE = 25

  def index
    @filters = {
      q: params[:q].to_s.strip
    }

    scope = apply_filters(Blueprint.includes(:creator).ordered)

    @total_count = scope.count
    @total_pages = [(@total_count.to_f / PER_PAGE).ceil, 1].max
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @page = @total_pages if @page > @total_pages

    @blueprints = scope.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  def new
    @blueprint = Blueprint.build_with_defaults(year: Time.current.year)
    @blueprint.ensure_default_rules
  end

  def create
    # Build without defaults to avoid duplicating rules when rules_attributes are posted
    @blueprint = Blueprint.new
    @blueprint.assign_attributes(blueprint_params)
    @blueprint.creator = current_user
    # If the client didn't send rules, seed defaults
    @blueprint.ensure_default_rules if blueprint_params[:rules_attributes].blank?

    if @blueprint.save
      handle_post_persist_response(@blueprint, :new)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @blueprint.status_published?
      redirect_to questions_blueprints_path, alert: "Blueprint publicado não pode ser editado." and return
    end

    if @blueprint.update(blueprint_params)
      handle_post_persist_response(@blueprint, :edit)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def publish
    if @blueprint.status_published?
      redirect_to questions_blueprints_path, alert: "Blueprint já foi publicado." and return
    end

    publish_and_redirect(@blueprint)
  end

  private

  def set_blueprint
    @blueprint = Blueprint.includes(:rules).find(params[:id])
    @blueprint.ensure_default_rules
  end

  def blueprint_params
    params.require(:blueprint).permit(
      :year,
      :modality,
      :name,
      :observations,
      :target_questions_per_area,
      :target_points_per_area,
      :version,
      rules_attributes: [
        :id,
        :area,
        :component,
        :quantity,
        :max_points,
        :rounding_mode
      ]
    )
  end

  def apply_filters(scope)
    return scope unless @filters[:q].present?

    query = "%#{@filters[:q].downcase}%"
    scope.where("LOWER(name) LIKE :query OR CAST(year AS TEXT) LIKE :query", query: query)
  end

  def handle_post_persist_response(blueprint, render_action)
    if publishing?
      publish_and_redirect(blueprint, render_action)
    else
      redirect_to edit_questions_blueprint_path(blueprint), notice: "Blueprint salvo como rascunho."
    end
  end

  def publish_and_redirect(blueprint, render_action = :edit)
    blueprint.publish!(current_user)
    redirect_to questions_blueprints_path, notice: "Blueprint publicado com sucesso."
  rescue Blueprint::PublicationError => e
    @publication_issues = e.issues
    @current_step = 4
    flash.now[:alert] = "Não foi possível publicar o blueprint. Revise os dados e tente novamente."
    render render_action, status: :unprocessable_entity
  end

  def publishing?
    ActiveModel::Type::Boolean.new.cast(params[:publish])
  end

  def set_current_step
    requested_step = params[:current_step].to_i
    requested_step = 1 if requested_step < 1
    max_step = 4
    requested_step = max_step if requested_step > max_step
    @current_step = requested_step
  end
end
