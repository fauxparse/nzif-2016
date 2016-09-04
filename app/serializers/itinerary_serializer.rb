class ItinerarySerializer < ActiveModel::Serializer
  attributes :id, :package_id, :activities, :packages, :participant

  def activities
    schedules_to_serialize.sort.map(&method(:serialize_schedule))
  end

  def packages
    ActiveModelSerializers::SerializableResource.new(object.packages)
  end

  private

  def schedules_to_serialize
    if instance_options[:full]
      festival.schedules.with_activity_details
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
    url = schedule_url(schedule)
    ActiveModelSerializers::SerializableResource.new(schedule, url: url)
      .as_json
      .merge(selected: object.selected?(schedule))
  end

  def schedule_url(schedule)
    Rails.application.routes.url_helpers
      .scheduled_activity_path(festival, schedule)
  end

  def festival
    object.registration.festival
  end
end
