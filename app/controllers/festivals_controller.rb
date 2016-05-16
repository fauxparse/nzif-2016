class FestivalsController < ApplicationController
  def index
    redirect_to festival_path(festival) if festival.present?
  end

  def show
  end
end
