module Admin::TimetablesHelper
  def activity_class_name(activity)
    activity = activity.activity if activity.respond_to?(:activity)
    activity.class.to_param.singularize.tr('_', '-')
  end

  def activity_data(activity)
    if activity.respond_to?(:activity_id)
      { id: activity.activity_id, "schedule-id" => activity.id }
    else
      { id: activity.id }
    end.merge(duration: (activity.duration / 30.minutes).ceil)
  end
end
