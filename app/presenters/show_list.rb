class ShowList < ScheduleList
  alias_method :shows, :schedules

  def initialize(festival)
    super(festival, type: Show)
  end
end
