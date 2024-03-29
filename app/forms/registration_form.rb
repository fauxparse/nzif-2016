class RegistrationForm
  include Cry

  attr_reader :festival
  attr_writer :step

  def initialize(festival, participant = nil)
    @festival = festival
    @participant = participant
  end

  def apply(params)
    self.step = params[:step]

    step.on(:success) do
      publish(:sign_in, user)
      advance!
    end

    step
      .on(:redirect) { |url| publish(:redirect, url) }
      .on(:error) { publish(:error, registration) }
      .apply(params)

  rescue ActiveModel::ValidationError
    publish(:error, registration)
  end

  def participant
    registration.participant || registration.build_participant
  end

  def user
    participant.user || participant.build_user
  end

  def step
    @step ||= steps.detect(&:pending?) ||
      Registration::Step::Finished.new(registration)
  end

  def step=(step_id)
    @step = steps.detect do |step|
      step.complete? && step.id == step_id.to_sym
    end if step_id.present?
  end

  def steps
    @steps ||= Registration::Step.list(registration)
  end

  def advance!
    @step = nil
    publish(complete? ? :complete : :continue, registration)
  end

  def complete?
    steps.all?(&:complete?)
  end

  def registration
    @registration ||= festival.registrations
      .find_or_initialize_by(participant: @participant)
  end

  def account
    @account ||= Account.new(registration)
  end

  def self.permitted_attributes
    Registration::Step.parameters
  end
end
