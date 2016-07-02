class RegistrationChecklist
  def initialize(registration)
    @registration = registration
  end

  STEPS = %i[paid_in_full].freeze

  def to_partial_path
    "checklist"
  end

  delegate :paid_in_full?, to: :account

  def as_json(options = {})
    return {} unless registration.present?

    STEPS.each.with_object({}) do |step, json|
      json[step] = send(:"#{step}?")
    end
  end

  private

  attr_accessor :registration

  def account
    @account ||= Account.new(registration)
  end
end
