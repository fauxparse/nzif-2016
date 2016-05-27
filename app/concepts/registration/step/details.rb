class Registration::Step::Details < Registration::Step
  def complete?
    [registration, participant, user].all?(&:persisted?)
  end

  def participant_state
    if user.persisted?
      participant.persisted? ? :existing_participant : :logged_in
    else
      :new_participant
    end
  end

  private

  def user
    @user ||= participant.try(:user)
  end

  def participant
    @participant ||= registration.participant
  end
end
