class Admin::VenuesController < Admin::Controller
  def index
    @venues = Venue.in_order.all
  end

  def new
    @venue = Venue.new
  end

  def create
    @venue = Venue.new(venue_params)
    if @venue.save
      render partial: @venue, object: @venue
    else
      render :new, status: :not_acceptable
    end
  end

  def edit
  end

  def update
    if venue.update(venue_params)
      render partial: venue, object: venue
    else
      render :edit, status: :not_acceptable
    end
  end

  def destroy
    venue.destroy
    redirect_to admin_venues_path
  end

  def reorder
    venue.remove_from_list
    venue.insert_at(params[:position].to_i)
    head :ok
  end

  private

  def venue_params
    params.require(:venue).permit(:name, :address)
  end

  def venue
    @venue ||= Venue.find(params[:id])
  end

  helper_method :venue
end
