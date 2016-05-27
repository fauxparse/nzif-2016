class RegistrationForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations
  extend ActiveModel::Translation

  attr_reader :festival, :participant
  attr_writer :step

  delegate :user, :name, to: :participant
  delegate :email, :password, :password_confirmation, to: :user

  def initialize(festival, participant = nil, params = {})
    @params = params
    @festival = festival
    @participant = find_or_build_participant(participant)
  end

  def step
    @step ||= steps.detect(&:pending?)
  end

  def step=(step_id)
    @step = steps.detect do |step|
      step.complete? && step.id == step_id.to_sym
    end if step_id.present?
  end

  def steps
    @steps ||= Registration::Step.list(registration)
  end

  def complete?
    steps.all?(&:complete?)
  end

  def registration
    @registration ||= festival.registrations
      .find_or_initialize_by(participant: participant)
  end

  def save!
    valid? && models.all?(&:save) || raise_validation_error
  end

  def valid?
    models.each(&:valid?) unless attempting_login?
    merge_errors
    errors.empty?
  end

  def params(attributes = nil)
    @permitted_params ||= if @params[:registration].blank?
      ActionController::Parameters.new.permit!
    else
      @params
        .require(:registration)
        .permit(*self.class.permitted_attributes)
    end
  end

  def existing_user?
    !user.new_record?
  end

  def existing_email
    participant && user.try(:email)
  end

  def existing_password
    nil
  end

  def self.permitted_user_attributes
    %i[
      email
      password
      password_confirmation
    ]
  end

  def self.permitted_participant_attributes
    %i[name]
  end

  def self.permitted_login_attributes
    %i[existing_email existing_password]
  end

  def self.permitted_attributes
    permitted_participant_attributes +
      permitted_user_attributes +
      permitted_login_attributes
  end

  private

  def models
    [user, participant, registration]
  end

  def find_or_build_participant(participant)
    if attempting_login?
      user = FindValidUser.new(login_attributes).user
      Participant.find_or_initialize_by(user: user).tap do |participant|
        if participant.user.blank?
          participant.build_user(login_attributes.slice[:email])
          errors.add(:existing_email, :invalid)
        end
      end
    else
      participant ||= params[:email] &&
        Participant.find_by(email: params[:email]) ||
        Participant.new
      participant.tap do |participant|
        participant.attributes =
          params.slice(*self.class.permitted_participant_attributes)
        participant.user ||= User.new(user_attributes)
      end
    end
  end

  def attempting_login?
    !login_attributes.blank?
  end

  def login_attributes
    {
      email: params[:existing_email],
      password: params[:existing_password]
    }.compact
  end

  def user_attributes
    params
      .slice(*self.class.permitted_user_attributes)
      .tap do |attributes|
        attributes[:email].try(:strip!)
        attributes[:email].try(:downcase!)
      end
  end

  def merge_errors
    models.each do |model|
      model.errors.each do |attr, message|
        errors.add(attr, message) unless errors[attr].include?(message)
      end
    end
  end

  def raise_validation_error
    raise ActiveModel::ValidationError.new(self)
  end
end
