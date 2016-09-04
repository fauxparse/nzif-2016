class FestivalsController < ApplicationController
  def index
    redirect_to festival_path(festival) if festival.present?
  end

  def show
    @summary = FestivalSummary.new(festival)
  end
end
