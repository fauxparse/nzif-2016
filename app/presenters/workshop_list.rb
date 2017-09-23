class WorkshopList < ScheduleList
  alias_method :workshops, :schedules

  def initialize(festival)
    super(festival, type: Workshop)
  end
end
