class ParticipantList
  attr_reader :festival

  def initialize(festival: nil, show_all: false)
    @festival = festival
    @show_all = show_all
  end

  def participants
    @participants = scope.with_user.by_name
  end

  def show_all?
    @show_all
  end

  def to_ary
    participants.all.map { |participant| Presenter.new(participant, festival) }
  end

  private

  class Presenter < SimpleDelegator
    alias_method :participant, :__getobj__
    attr_reader :festival

    def initialize(participant, festival)
      super(participant)
      @festival = festival
    end

    def verified_user?
      user.present?
    end

    def admin?
      verified_user? && user.admin?
    end

    def registered?
      registration.present?
    end

    def registration
      participant.registrations.detect do |registration|
        registration.festival_id == festival.id
      end
    end
  end

  def scope
    if show_all?
      Participant.includes(:registrations, :user)
    else
      Participant
        .includes(:registrations, :user)
        .references(:registrations)
        .where("registrations.festival_id = ?", festival.id)
        .distinct("participants.id")
    end
  end
end
