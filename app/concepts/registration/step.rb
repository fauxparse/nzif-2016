class Registration::Step
  attr_reader :registration

  def initialize(registration)
    @registration = registration
  end

  def id
    self.class.name.demodulize.underscore.to_sym
  end

  def to_partial_path
    id.to_s
  end

  def name
    I18n.translate("registrations.steps.#{id}")
  end

  def complete?
    false
  end

  def pending?
    !complete?
  end

  def state
    if complete?
      :complete
    else
      :pending
    end
  end

  def self.list(registration)
    %i[details package payment].map { |step| get(registration, step) }
  end

  def self.get(registration, id)
    const_get(id.to_s.camelize).new(registration)
  end
end
