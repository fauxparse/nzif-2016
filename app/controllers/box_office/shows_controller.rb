class BoxOffice::ShowsController < BoxOffice::Controller
  def index
    @shows = ShowList.new(festival)
  end

  def show
    @show = ShowBookings.new(schedule)
  end

  private

  def schedule
    @schedule ||= festival.schedules
      .includes(:activity, :venue, :selections => { :registration => :participant })
      .find(params[:id])
  end
end
