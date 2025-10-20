class BookletsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Página de booklets - apenas título
  end

  def generate
    blueprint = Blueprint.find(params.require(:blueprint_id))
    area_key = params.require(:area)

    booklet_snapshot = BookletGenerator.new(blueprint: blueprint, area_key: area_key, actor: current_user).call

    render json: {
      booklet_snapshot_id: booklet_snapshot.id,
      checksum: booklet_snapshot.checksum,
      totals: booklet_snapshot.payload.fetch("totals"),
      blueprint: booklet_snapshot.payload.fetch("blueprint"),
      area: booklet_snapshot.payload.fetch("area")
    }, status: :created
  rescue BookletGenerator::GenerationError, ActiveRecord::RecordNotFound => e
    render json: { errors: Array(e.message) }, status: :unprocessable_entity
  end
end
