class ScheduleSerializer < ActiveModel::Serializer
  attributes :id, :type, :name, :starts_at, :ends_at, :full, :facilitators,
    :image
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

  def image
    if object.activity.image?
      object.activity.image.url(:medium)
    else
      "http://unsplash.it/640/360/?image=#{object.id % 40 + 1040}"
    end
  end
end
