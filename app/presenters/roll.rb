class Roll
  attr_reader :schedule

  def initialize(schedule)
    @schedule = schedule
  end

  def full?
    schedule.full
  end

  def limited?
    schedule.limited?
  end

  def to_partial_path
    "rolls/roll"
  end

  def count
    @count ||= participants.count
  end

  def limit
    if limited?
      schedule.maximum
    else
      count
    end
  end

  def participants
    @participants ||= schedule.participants
  end

  def activity_name
    activity.name
  end

  def times
    [schedule_details.date, schedule_details.times].join(", ")
  end

  def summary
    OneLineActivitySummary.new(activity)
  end

  def self.for_activity(activity)
    activity.schedules.in_order.map { |schedule| new(schedule) }
  end

  private

  def schedule_details
    @schedule_details ||= ScheduleDetails.new(schedule)
  end

  def activity
    schedule.activity
  end
end
