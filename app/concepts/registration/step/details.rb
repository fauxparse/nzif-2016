class Registration::Step::Details < Registration::Step
  delegate :name, :email, to: :participant
  delegate :password, :password_confirmation, to: :participant

  def complete?
    [registration, participant, user].all?(&:persisted?)
  end

  def valid?
    models.each do |model|
      unless model.valid?
        model.errors.each do |attr, message|
          errors[attr] << message unless errors[attr].include?(message)
        end
      end
    end
    super
  end

  def participant_state
    if user.try(:persisted?)
      participant.persisted? ? :existing_participant : :logged_in
    else
      :new_participant
    end
  end

  def existing_email
    participant && user.try(:email)
  end

  def existing_password
    nil
  end

  def existing_user?
    !user.new_record?
  end

  def self.parameters
    user_parameters + participant_parameters
  end

  def self.user_parameters
    %i[email password password_confirmation]
  end

  def self.participant_parameters
    %i[name]
  end

  private

  def apply_filtered_parameters(params)
    registration.participant = find_or_build_participant(params) \
      if participant.new_record?
    participant.attributes = params.slice(*self.class.participant_parameters)
    user.attributes = params.slice(*self.class.user_parameters)
    valid? && [user, participant, registration].each(&:save)
  end

  def find_or_build_participant(params)
    if user.new_record?
      participant_by_email(params[:email]) || participant
    else
      user.participants.first || user.build_participant
    end
  end

  def participant_by_email(email)
    email &&
      Participant.find_by(email: email) ||
      User.includes(:participant).find_by(email: email).try(:participant) ||
      Participant.new
  end

  def models
    [user, participant, registration]
  end

  def user
    participant.user || participant.build_user
  end

  def participant
    registration.participant || registration.build_participant
  end

  def registration_for_participant(participant)
    festival.registrations.find_by(participant: participant) ||
      registration
  end
end
