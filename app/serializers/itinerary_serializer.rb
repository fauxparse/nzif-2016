class ItinerarySerializer < ActiveModel::Serializer
  attributes :id, :activities

  def activities
    schedules_to_serialize.sort.map do |schedule|
      serialize_schedule(schedule)
    end
  end

  private

  def schedules_to_serialize
    if instance_options[:full]
      object.registration.festival.schedules.with_activity_details
    else
      object.schedules
    end
  end

  def serialize_schedule(schedule)
    ActiveModelSerializers::SerializableResource.new(schedule)
      .as_json
      .merge(selected: object.selected?(schedule))
  end
end
