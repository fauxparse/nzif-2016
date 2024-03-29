class Itinerary
  include ActiveModel::Validations

  alias :read_attribute_for_serialization :send

  validate :check_package_limits
  validate :check_activity_limits

  attr_reader :registration
  delegate :id, :participant, :festival, to: :registration

  def initialize(registration)
    @registration = registration
    registration.package = best_available_or_current_package
  end

  def update(params)
    self.selections = params[:selections] || []
    registration.package = best_available_or_current_package

    save && send_confirmation && true
  end

  def save
    valid? && registration.save && @full_schedules.empty?
  end

  def valid?
    @full_schedules = []
    super
  end

  def schedules
    (selected_schedules + facilitating_schedules + general_admission_schedules)
      .sort.uniq
  end

  def full_schedules
    @full_schedules || []
  end

  def selected?(schedule)
    selections.map(&:schedule_id).include?(schedule.id)
  end

  def complete?
    selected = selections_by_activity_type
    package.allocations.all? do |allocation|
      allocation.unlimited? ||
      selected[allocation.activity_type].size == allocation.maximum
    end
  end

  def requires_additional_payment?
    Account.new(registration).requires_additional_payment?
  end

  def to_model
    registration
  end

  def allocations
    package.allocations.select(&:limited?).sort
  end

  def packages
    registration.festival.packages.ordered.with_allocations.with_prices
  end

  def package
    registration.package || packages.last
  end

  def package_id
    package.id
  end

  def to_partial_path
    'itinerary'
  end

  def selections
    registration.selections.reject(&:marked_for_destruction?)
  end

  private

  def selected_schedules
    schedule_scope.find(selections.map(&:schedule_id))
  end

  def facilitating_schedules
    schedule_scope
      .references(:faciliatators)
      .where('facilitators.participant_id = ?', registration.participant_id)
  end

  def general_admission_schedules
    schedule_scope
      .references(:activities)
      .where('activities.type IN (?)', general_admission_activity_types)
  end

  def general_admission_activity_types
    registration.package.allocations.select(&:unlimited?).map(&:activity_type)
  end

  def schedule_scope
    registration.festival.schedules.with_activity_details
  end

  def selections=(ids)
    desired = registration.festival.schedules.find(ids)
    selections.reject { |s| desired.include?(s.schedule) }
      .each(&:mark_for_destruction)
    desired.reject(&method(:selected?))
      .each { |schedule| registration.selections.build(schedule: schedule) }
  end

  def empty_selections
    package.allocations.each.with_object({}) do |allocation, hash|
      hash[allocation.activity_type] = []
    end
  end

  def selections_by_activity_type
    empty_selections.merge(
      selections.group_by { |selection|
        selection.schedule.activity.class
      }
    )
  end

  def package_allocation(type)
    package.allocations.detect { |allocation| allocation.activity_type == type }
  end

  def check_package_limits
    selections_by_activity_type.each do |type, selections|
      allocation = package_allocation(type)
      errors.add(:base, *too_many(allocation, selections)) \
        unless allocation.accepts?(selections.size)
    end
  end

  def too_many(allocation, selections)
    if allocation.allowed?
      [:too_many, { type: allocation.name, max: allocation.maximum }]
    else
      [:not_allowed, { type: allocation.name }]
    end
  end

  def check_activity_limits
    selections.select(&:new_record?).each do |selection|
      if selection.schedule.full?
        @full_schedules << selection.schedule
        registration.selections.delete(selection)
      end
    end
  end

  def activity_full(schedule)
    [:activity_full, { activity: schedule.name }]
  end

  def send_confirmation
    Postman.itinerary(registration).deliver_later
  end

  def best_available_package
    selected = selections_by_activity_type
    best = packages.detect do |package|
      package.allocations.select(&:limited?).all? do |allocation|
        allocation.accepts?(selected[allocation.activity_type].count)
      end
    end
  end

  def best_available_or_current_package
    [best_available_package, registration.package]
      .compact
      .sort_by(&:position)
      .last || packages.last
  end
end
