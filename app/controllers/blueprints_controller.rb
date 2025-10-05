class BlueprintsController < ApplicationController
  before_action :authenticate_user!

  SAMPLE_BLUEPRINTS = Array.new(60) do |index|
    {
      id: 2000 + index + 1,
      title: "Blueprint ##{format('%02d', index + 1)}"
    }
  end.freeze

  def index
    @filters = {
      q: params[:q].to_s.strip
    }

    filtered = filter_blueprints

    @per_page = 25
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @total_pages = [(filtered.size / @per_page.to_f).ceil, 1].max
    @page = @total_pages if @page > @total_pages
    offset = (@page - 1) * @per_page
    @blueprints = filtered.slice(offset, @per_page) || []
  end

  private

  def filter_blueprints
    query = @filters[:q].presence

    SAMPLE_BLUEPRINTS.select do |blueprint|
      query.nil? || blueprint[:title].downcase.include?(query.downcase)
    end
  end
end
