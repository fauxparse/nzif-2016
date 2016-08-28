class Timetable
  attr_reader :festival

  def initialize(festival)
    @festival = festival
  end

  def dates
    (festival.start_date..festival.end_date)
  end

  def times(date = dates.first)
    (18...50).map { |i| date.midnight + i * 30.minutes }
  end

  def length
    (festival.end_date - festival.start_date).to_i + 1
  end

  def activities
    @activities = festival.activities.alphabetically.group_by(&:class)
    Hash[Activity.types.map { |type| [type, @activities[type] || []] }]
  end

  def schedule
    @schedules ||= all_activities.flat_map(&:schedules).group_by(&:timeslot)
  end

  def scheduled_at(time)
    schedule.select { |timeslot, _| timeslot.first == time }
  end

  private

  def all_activities
    @all_activities ||= festival.activities.includes(:schedules).all
  end
end
