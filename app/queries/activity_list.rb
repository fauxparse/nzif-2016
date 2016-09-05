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

  def find(id)
    scope.find_by!(slug: id)
  end

  def title
    if type.present?
      type.model_name.human.pluralize
    else
      I18n.t('activities.index.title', year: festival.year)
    end
  end

  def intro
    I18n.t("intro.#{(type || :all).to_param}", scope: 'activities.index')
  end

  private

  def activity_subclass(type)
    types.detect { |t| t.to_param == type }
  end

  def scope
    scope = festival.activities
    scope = scope.by_type(type) if type.present?
    scope.includes(:facilitators, :schedules)
      .references(:schedules)
      .order('schedules.starts_at')
  end
end
