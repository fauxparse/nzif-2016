class ScheduledActivity
  include PrettyPresenters

  NOON = 14

  def initialize(schedule)
    @schedule = schedule
  end

  def summary
    [
      I18n.t(
        activity.class.name.demodulize.underscore,
        timing: timing,
        scope: 'scheduled_activities.summaries'
      ),
      facilitators
    ].reject(&:blank?).join(' with ')
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

  def facilitators
    activity.facilitators.to_a.to_sentence
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

  def timing
    key = if start_time.hour > NOON || end_time.hour < NOON
      :half_day
    else
      :full_day
    end
    I18n.t(key, scope: 'scheduled_activities.timing')
  end

  def date_and_time(schedule)
    [
      I18n.l(schedule.starts_at, format: :short),
      I18n.l(schedule.ends_at, format: :full)
    ].join(' – ')
  end
end
