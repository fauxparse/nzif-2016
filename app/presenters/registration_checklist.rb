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

    def pending
      account.pending_payments.sort_by(&:created_at)
    end
  end

  class Itinerary < Step
    def complete?
      itinerary.complete?
    end

    def itinerary
      @itinerary ||= ::Itinerary.new(registration)
    end

    def description
      picked = if selections.empty?
        I18n.t('registrations.checklist.itinerary.nothing')
      elsif selected_description.blank?
        I18n.t('registrations.checklist.itinerary.everything')
      else
        I18n.t(
          'registrations.checklist.itinerary.picked',
          selected: selected_description
        )
      end

      I18n.t(
        'registrations.checklist.itinerary.paid_for',
        package: package_description
      ) + picked
    end

    def next_steps(url)
      I18n.t('registrations.checklist.itinerary.next_steps', url: url)
        .html_safe
    end

    private

    def package_description
      allocations.map do |allocation|
        pluralize(allocation, allocation.maximum)
      end.to_sentence
    end

    def selected_description
      allocations.each.with_object([]) do |allocation, result|
        count = selections[allocation.activity_type].try(:size) || 0
        result << pluralize(allocation, count) if count < allocation.maximum
      end.to_sentence
    end

    def allocations
      @allocations ||= registration.package.allocations.all.select(&:limited?)
    end

    def selections
      @selections ||= registration.selections.includes(:schedule => :activity)
        .group_by { |selection| selection.schedule.activity.class }
    end

    def pluralize(allocation, count)
      "#{count} #{allocation.name.pluralize(count)}"
    end
  end
end
