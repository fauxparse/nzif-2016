class FacilitatorDetails
  include PrettyPresenters

  def initialize(facilitator)
    @participant = facilitator.participant
  end

  def name
    participant.name
  end

  def avatar
    participant.avatar.url(:large)
  end

  def bio
    pretty(participant.bio)
  end

  def participant_id
    participant.id
  end

  def self.from_activity(activity)
    activity.facilitators.includes(:participant).all.map do |facilitator|
      FacilitatorDetails.new(facilitator)
    end
  end

  private

  attr_reader :participant
end
