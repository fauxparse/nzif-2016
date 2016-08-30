class ScheduleDetails
  include PrettyPresenters

  def initialize(schedule, registration)
    @schedule = schedule
    @registration = registration
  end

  def full?
    schedule.full?
  end

  def selected?
    registration.present? &&
      registration.selections.where(activity_id: activity_id).exists?
  end

  def date
    I18n.l(schedule.starts_at.to_date, format: :full)
  end

  def times
    [
      I18n.l(schedule.starts_at, format: :short),
      I18n.l(schedule.ends_at, format: :ampm)
    ].join(' – ')
  end

  def self.from_activity_and_registration(activity, registration)
    activity.schedules.includes(:venue).in_order.all.map do |schedule|
      ScheduleDetails.new(schedule, registration)
    end
  end

  private

  attr_reader :schedule, :registration

  delegate :activity_id, to: :schedule
end
