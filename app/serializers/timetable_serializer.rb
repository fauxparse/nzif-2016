class TimetableSerializer < ActiveModel::Serializer
  attributes :activities, :schedules

  def activities
    object.activities.values.flatten.map(&method(:serialize_activity))
  end

  def schedules
    object.schedule.values.flatten.map(&method(:serialize_schedule))
  end

  private

  def serialize_activity(activity)
    ActiveModelSerializers::SerializableResource.new(activity).as_json
  end

  def serialize_schedule(schedule)
    TimetableScheduleSerializer.new(schedule).as_json
  end
end
