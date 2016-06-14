module Admin::TimetablesHelper
  def activity_class_name(activity)
    activity.class.to_param.singularize.tr('_', '-')
  end
end
