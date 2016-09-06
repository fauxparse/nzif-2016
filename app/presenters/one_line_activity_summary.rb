class OneLineActivitySummary
  NOON = 13

  def initialize(activity)
    @activity = activity
  end

  def to_s
    [
      I18n.t(
        activity_type,
        timing: timing,
        scope: 'scheduled_activities.summaries'
      ),
      facilitators
    ].reject(&:blank?).join(' with ')
  end

  private

  attr_reader :activity

  def facilitators
    activity.facilitators.to_a.to_sentence
  end

  def schedule
    activity.schedules.first
  end

  def timing
    key = if schedule.blank? || start_time.hour >= NOON || end_time.hour <= NOON
      :half_day
    else
      :full_day
    end
    I18n.t(key, scope: 'scheduled_activities.timing')
  end

  def start_time
    schedule.starts_at
  end

  def end_time
    schedule.ends_at
  end

  def activity_type
    if workshop_with_has_attached_show?
      :workshop_with_show
    else
      activity.class.name.demodulize.underscore.to_sym
    end
  end

  def workshop_with_has_attached_show?
    activity.is_a?(Workshop) &&
      related_activities.any? { |r| r.is_a?(Show) }
  end

  def related_activities
    activity.related_activities.includes(:child).all.map(&:child)
  end
end
