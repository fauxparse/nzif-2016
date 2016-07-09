class ItinerariesController < ApplicationController
  wrap_parameters :itinerary, include: [:selections]

  before_action :load_itinerary

  def show
    respond_to do |format|
      format.html
      format.json { render json: @itinerary }
      format.pdf do
        render pdf: 'itinerary.pdf', layout: 'pdf', show_as_html: params[:debug].present?
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.json { render json: @itinerary, full: true }
    end
  end

  def update
    status = @itinerary.update(itinerary_params) ? :ok : :not_acceptable
    render json: @itinerary, full: true, status: status
  end

  private

  def load_itinerary
    redirect_to register_path unless registration.present?
    @itinerary = Itinerary.new(registration)
  end

  def itinerary_params
    params.require(:itinerary).permit(selections: [])
  end
end
