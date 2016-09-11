class WorkshopRolls
  attr_reader :participant, :festival

  def initialize(participant, festival)
    @participant = participant
    @festival = festival
  end

  def rolls
    activities.flat_map { |activity| Roll.for_activity(activity) }
  end

  private

  def activities
    festival.activities
      .includes(
        :facilitators,
        :schedules => { :selections => { :registration => :participant } }
      )
      .references(:facilitators)
      .where('facilitators.participant_id = ?', @participant.id)
      .where('activities.type = ?', Workshop)
  end
end
