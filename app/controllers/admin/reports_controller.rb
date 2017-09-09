class Admin::ReportsController < Admin::Controller
  def index
  end

  def shows
    @activities = ShowList.new(festival)
    render 'activities'
  end

  def show
    @activity = ShowBookings.new(schedule)
    render 'activity'
  end

  def workshops
    @activities = WorkshopList.new(festival)
    render 'activities'
  end

  def accounts
    @report = AccountingReport.new(festival)

    respond_to do |format|
      format.csv do
        send_data @report.to_csv, filename: @report.filename
      end
    end
  end

  private

  def schedule
    @schedule ||= festival.schedules
      .includes(:activity, :venue, :selections => { :registration => :participant })
      .find(params[:id])
  end
end
