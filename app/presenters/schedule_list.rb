class ScheduleList
  attr_reader :festival, :type

  def initialize(festival, type: nil)
    @festival = festival
    @type = type
  end

  def to_ary
    schedules.map { |schedule| ShowBookings.new(schedule) }
  end

  def title
    "#{type.name.humanize} bookings"
  end

  alias to_a to_ary

  def schedules
    festival
      .schedules
      .includes(:activity, :venue)
      .references(:activity)
      .where('activities.type' => type.name)
      .order(:starts_at)
  end
end
