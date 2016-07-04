class ItinerariesController < ApplicationController
  def show
    @itinerary = Itinerary.new(registration)
    respond_to do |format|
      format.html
      format.json { render json: @itinerary }
    end
  end

  def edit
    @itinerary = Itinerary.new(registration)
    respond_to do |format|
      format.html
      format.json { render json: @itinerary, full: true }
    end
  end
end
