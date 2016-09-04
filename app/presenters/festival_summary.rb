class FestivalSummary
  attr_reader :festival

  def initialize(festival)
    @festival = festival
  end

  def activities
    festival.schedules.includes(:activity)
      .where('activities.type' => [Workshop, Show])
      .group_by { |schedule| schedule.activity.class }
      .to_a
      .sort_by(&:first)
  end

  def participants
    festival.registrations.count
  end
end
