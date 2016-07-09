require 'icalendar'
require 'icalendar/tzinfo'

class Calendar
  def initialize(registration)
    @registration = registration
  end

  def to_ics
    calendar.to_ical
  end

  private

  attr_reader :registration

  def itinerary
    @itinerary ||= Itinerary.new(registration)
  end

  def calendar
    @calendar ||= Icalendar::Calendar.new.tap do |calendar|
      add_events(calendar)
    end
  end

  def add_events(calendar)
    timezone = Time.zone.tzinfo

    itinerary.schedules.each do |schedule|
      calendar.event do |event|
        calendar.add_timezone(timezone.ical_timezone(schedule.starts_at))
        venue = schedule.venue

        event.dtstart = Icalendar::Values::DateTime.new(schedule.starts_at)
        event.dtend = Icalendar::Values::DateTime.new(schedule.ends_at)
        event.summary = schedule.activity.name
        event.location = [venue.name, venue.address].join(', ') if venue
      end
    end
  end

  def schedules
    @schedules ||= selected_schedules + general_admission_schedules
  end

  def selected_schedules
    schedule_scope.find(registration.selections.map(&:schedule_id))
  end

  def general_admission_schedules
    schedule_scope
      .references(:activities)
      .where('activities.type IN (?)', general_admission_activity_types)
  end

  def general_admission_activity_types
    registration.package.allocations.select(&:unlimited?).map(&:activity_type)
  end

  def schedule_scope
    registration.festival.schedules.with_activity_details
  end

end
