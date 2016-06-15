class Admin::TimetablesController < Admin::Controller
  def show
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
