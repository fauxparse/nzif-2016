class ActivityList
  attr_reader :festival, :type

  def initialize(festival, type: nil)
    @festival = festival
    @type = activity_subclass(type)
  end

  def types
    Activity.types
  end

  def other_types
    [Workshop, Show] - [type]
  end

  def type_name
    type.model_name.human
  end

  def to_ary
    scope.all
  end

  def find(id)
    scope.find_by!(slug: id)
  end

  def random(n = 3)
    scope.reorder('RANDOM()').limit(n)
  end

  private

  def activity_subclass(type)
    types.detect { |t| t.to_param == type } || types.first
  end

  def scope
    festival.activities.by_type(type).alphabetically
      .includes(:facilitators, :schedules)
  end
end
