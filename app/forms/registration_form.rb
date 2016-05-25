class RegistrationForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations
  extend ActiveModel::Naming

  attr_reader :festival, :attributes

  delegate :participant, to: :registration
  delegate :name, :email, to: :participant
  delegate :name=, to: :participant
  delegate :password, :password_confirmation,
    :password=, :password_confirmation=,
    to: :user

  validate :validate_child_objects

  def initialize(festival, participant, params)
    @festival = festival
    @participant = participant

    assign_attributes(permitted_attributes(params))
  end

  def save!
    registration.transaction do
      validate!
      user.save!
      participant.save!
      registration.save!
    end
  end

  def registration
    @registration ||= new_or_existing_registration.tap do |registration|
      registration.build_participant unless registration.participant.present?
    end
  end

  def user
    participant.user || participant.build_user
  end

  def existing_user?
    !user.new_record?
  end

  def email=(value)
    (existing_user? ? participant : user).email = value
  end

  def self.permitted_parameters
    new_user_parameters
  end

  def step
    if !existing_user?
      :details
    else
      :payment
    end
  end

  def steps
    %i[details package payment]
  end

  private

  def new_or_existing_registration
    festival.registrations.find_or_initialize_by(participant: @participant)
  end

  def self.new_user_parameters
    %i[
      name
      email
      password
      password_confirmation
    ]
  end

  def permitted_parameters
    self.class.permitted_parameters
  end

  def permitted_attributes(params)
    return ActionController::Parameters.new.permit! \
      if params[:registration].blank?

    params
      .require(:registration)
      .permit(*permitted_parameters)
  end

  def validate_child_objects
    [registration, participant, user].each do |object|
      object.validate
      object.errors.each do |attr, message|
        errors.add(attr, message)
      end
    end
  end
end
