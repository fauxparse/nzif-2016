class ItinerariesController < ApplicationController
  wrap_parameters :itinerary, include: [:selections]

  before_action :load_itinerary

  def show
    respond_to do |format|
      format.html do
        redirect_to register_path unless registration.complete?
      end
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
    success = @itinerary.update(itinerary_params)

    respond_to do |format|
      format.html do
        if !success
          render :edit
        elsif @itinerary.requires_additional_payment?
          redirect_to account_path
        else
          redirect_to itinerary_path
        end
      end
      format.json do
        render json: @itinerary, full: true, \
          status: success ? :ok : :not_acceptable
      end
    end
  end

  def email
    Postman.itinerary(registration).deliver_later
    head :ok
  end

  private

  def load_itinerary
    redirect_to register_path unless registration.present?
    @itinerary = Itinerary.new(registration)
  end

  def itinerary_params
    if params[:itinerary].present?
      params.require(:itinerary).permit(selections: [])
    else
      {}
    end
  end
end
