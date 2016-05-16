class FestivalsController < ApplicationController
  def index
    redirect_to "/#{festival.year}" if festival.present?
  end

  def show
  end
end
