class ScheduleSerializer < ActiveModel::Serializer
  attributes :id, :name
  attribute :url, if: :include_url?

  def include_url?
    instance_options[:url].present?
  end

  def url
    instance_options[:url]
  end
end
