class ScheduleSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :starts_at, :ends_at, :full, :facilitators
  attribute :url, if: :include_url?

  def include_url?
    url.present?
  end

  def url
    instance_options[:url]
  end

  def type
    object.activity.class.name.underscore
  end

  def starts_at
    object.starts_at.iso8601
  end

  def ends_at
    object.ends_at.iso8601
  end

  def full
    object.full?
  end

  def facilitators
    object.activity.facilitators.map do |facilitator|
      ActiveModelSerializers::SerializableResource.new(facilitator.participant)
    end
  end
end
