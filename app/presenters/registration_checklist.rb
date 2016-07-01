class RegistrationChecklist
  def initialize(registration)
    @registration = registration
  end

  def to_partial_path
    "checklist"
  end

  delegate :paid_in_full?, to: :account

  private

  attr_accessor :registration

  def account
    @account ||= Account.new(registration)
  end
end
