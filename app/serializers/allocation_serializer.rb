class AllocationSerializer < ActiveModel::Serializer
  attributes :type, :singular, :plural, :limit

  def type
    activity_type.name.underscore
  end

  def singular
    activity_type.model_name.human
  end

  def plural
    singular.pluralize
  end

  def limit
    object.maximum
  end

  delegate :activity_type, to: :object
end
