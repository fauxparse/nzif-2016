class Admin::TimetablesController < Admin::Controller
  def show
  end

  private

  def timetable
    @timetable ||= Timetable.new(festival)
  end

  helper_method :timetable
end
