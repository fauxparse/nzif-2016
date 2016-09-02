class RegistrationChecklist
  def initialize(registration)
    @registration = registration
  end

  def as_json(options = {})
    return {} unless registration.present?

    steps.each.with_object({}) do |step, json|
      json[step.to_partial_path] = step.complete?
    end
  end

  def steps
    @steps ||= [Payment, Itinerary].map { |step| step.new(registration) }
  end

  def to_ary
    steps
  end

  private

  attr_accessor :registration

  class Step
    attr_reader :registration

    def initialize(registration)
      @registration = registration
    end

    def complete?
      false
    end

    def to_partial_path
      "registrations/checklist/#{self.class.name.demodulize.underscore}"
    end
  end

  class Payment < Step
    def complete?
      account.paid_in_full?
    end

    def account
      @account ||= Account.new(registration)
    end
  end

  class Itinerary < Step
    def complete?
      itinerary.complete?
    end

    def itinerary
      @itinerary ||= ::Itinerary.new(registration)
    end
  end
end
