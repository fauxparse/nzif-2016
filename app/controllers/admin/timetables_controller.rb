class Admin::TimetablesController < Admin::Controller
  def show
    respond_to do |format|
      format.html
      format.json { render json: timetable }
    end
  end

  private

  def festival_scope
    Festival.with_schedule
  end

  def timetable
    @timetable ||= Timetable.new(festival)
  end

  helper_method :timetable
end
