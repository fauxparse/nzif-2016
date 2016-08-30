class ScheduledActivity
  include PrettyPresenters

  def initialize(schedule)
    @schedule = schedule
  end

  def summary
    OneLineActivitySummary.new(activity).to_s
  end

  def dates_and_times
    date_and_time(schedule).tap do |result|
      count = activity.schedules.count - 1
      result << I18n.t('scheduled_activities.more', count: count) if count > 0
    end
  end

  def description
    pretty(activity.description)
  end

  def limit
    if schedule.limited?
      limit = pluralize(schedule.maximum, Participant.model_name.human.downcase)
      I18n.t('scheduled_activities.limit', limit: limit)
    end
  end

  def grade
    activity.grade
  end

  def recommendation
    I18n.t(grade, scope: 'activities.grades')
  end

  private

  attr_reader :schedule

  def activity
    schedule.activity
  end

  def start_time
    schedule.starts_at
  end

  def end_time
    schedule.ends_at
  end

  def date_and_time(schedule)
    [
      I18n.l(schedule.starts_at, format: :short),
      I18n.l(schedule.ends_at, format: :full)
    ].join(' – ')
  end
end
