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

  def timetable_editor_component(timetable)
    mithril_component(
      'TimetableEditor',
      timetable_component_data(timetable),
      class: 'timetable-container'
    )
  end

  def grouped_activities_for_select(activities)
    activities
      .group_by { |activity| activity.class.model_name.human.pluralize }
      .map { |group, activities|
        [
          group,
          activities.sort_by(&:name).map { |activity|
            [activity.name, activity.id]
          }
        ]
      }
  end

  private

  def timetable_component_data(timetable)
    {
      title: t('admin.timetables.show.title'),
      subtitle: date_range(timetable.dates.first, timetable.dates.last),
      start_date: timetable.dates.first,
      end_date: timetable.dates.last
    }
  end
end
