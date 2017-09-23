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
    if type
      "#{type.name.humanize} bookings"
    else
      'Bookings'
    end
  end

  alias to_a to_ary

  def schedules
    scope = festival
      .schedules
      .includes(:activity, :venue)
      .references(:activity)
      .order(:starts_at)
      .where('activities.type' => available_types)
    scope
  end

  private

  def available_types
    if type
      [type]
    else
      festival
        .packages
        .flat_map { |p| p.allocations.select(&:limited?).map(&:activity_type) }
        .uniq
    end
  end
end
