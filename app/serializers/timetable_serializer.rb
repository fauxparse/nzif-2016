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
    {
      id: schedule.id,
      start: schedule.starts_at,
      end: schedule.ends_at,
      activity_id: schedule.activity_id
    }
  end
end
