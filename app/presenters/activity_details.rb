class ActivityDetails
  include PrettyPresenters

  def initialize(activity, registration)
    @activity = activity
    @registration = registration
  end

  def title
    activity.name
  end

  def type
    activity.class
  end

  def image
    activity.image.url(:large)
  end

  def name
    activity.name
  end

  def summary
    OneLineActivitySummary.new(activity).to_s
  end

  def description
    pretty(activity.description)
  end

  def facilitators
    FacilitatorDetails.from_activity(activity)
  end

  def schedules
    ScheduleDetails.from_activity_and_registration(activity, registration)
  end

  def graded?
    grade.present?
  end

  def grade
    activity.grade unless activity.unknown_grade?
  end

  private

  attr_reader :activity, :registration
end
