class TimetableScheduleSerializer < ActiveModel::Serializer
  attributes :id, :start, :end, :activity_id

  def start
    object.starts_at
  end

  def end
    object.ends_at
  end
end
