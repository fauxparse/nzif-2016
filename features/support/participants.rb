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
    FactoryGirl.create(:user, email: participant_email)
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
end

World(ParticipantHelpers)
