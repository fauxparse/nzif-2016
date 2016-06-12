class ActivityList
  attr_reader :festival, :type

  def initialize(festival, type: nil)
    @festival = festival
    @type = activity_subclass(type)
  end

  def types
    Activity.types
  end

  def type_name
    type.model_name.human
  end

  def to_ary
    scope.all
  end

  private

  def activity_subclass(type)
    types.detect { |t| t.to_param == type } || types.first
  end

  def scope
    festival.activities.by_type(type).alphabetically
  end
end
