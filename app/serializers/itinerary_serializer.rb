class ItinerarySerializer < ActiveModel::Serializer
  attributes :id, :activities, :allocations

  def activities
    schedules_to_serialize.sort.map do |schedule|
      serialize_schedule(schedule)
    end
  end

  def allocations
    object.allocations.map(&method(:serialize_allocation))
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
    object.allocations.map(&:activity_type)
  end

  def serialize_schedule(schedule)
    ActiveModelSerializers::SerializableResource.new(schedule)
      .as_json
      .merge(selected: object.selected?(schedule))
  end

  def serialize_allocation(allocation)
    ActiveModelSerializers::SerializableResource.new(allocation)
  end
end
