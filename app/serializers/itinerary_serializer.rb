class ItinerarySerializer < ActiveModel::Serializer
  attributes :id, :package_id, :activities, :packages

  def activities
    schedules_to_serialize.sort.map(&method(:serialize_schedule))
  end

  def packages
    ActiveModelSerializers::SerializableResource.new(object.packages)
  end

  private

  def schedules_to_serialize
    if instance_options[:full]
      object.registration.festival.schedules.with_activity_details
        .references(:activities)
        .where('activities.type IN (?)', activity_types)
    else
      object.schedules
    end
  end

  def activity_types
    [Workshop, Show]
  end

  def serialize_schedule(schedule)
    url = activity_url(schedule.activity)
    ActiveModelSerializers::SerializableResource.new(schedule, url: url)
      .as_json
      .merge(selected: object.selected?(schedule))
  end

  def activity_url(activity)
    Rails.application.routes.url_helpers
      .activity_path(activity.festival, activity.class, activity)
  end
end
