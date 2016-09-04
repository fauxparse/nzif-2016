module ParticipantHelpers
  def create_participant(assign_user = false)
    FactoryGirl.create(
      :participant,
      name: participant_name,
      email: participant_email,
      user: (create_user if assign_user)
    )
  end

  def create_user
    FactoryGirl.create(:user, name: participant_name, email: participant_email)
  end

  def participant_name
    "Alice"
  end

  def participant_email
    "alice@example.com"
  end

  def password
    "p4$$w0rd!"
  end

  def participant
    @participant ||= create_participant
  end

  def admin
    @admin ||= FactoryGirl.create(:admin)
  end
end

World(ParticipantHelpers)
