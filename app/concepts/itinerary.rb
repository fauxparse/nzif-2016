class Itinerary
  include ActiveModel::Validations

  alias :read_attribute_for_serialization :send

  validate :check_package_limits
  validate :check_activity_limits

  attr_reader :registration
  delegate :id, :package, to: :registration

  def initialize(registration)
    @registration = registration
  end

  def update(params)
    self.selections = params[:selections] || []
    save
  end

  def save
    valid? && registration.save
  end

  def schedules
    Schedule.with_activity_details.find(selections.map(&:schedule_id))
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

  def to_model
    registration
  end

  def allocations
    package.allocations.select(&:limited?).sort
  end

  private

  def selections
    registration.selections.reject(&:marked_for_destruction?)
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
      errors.add(:base, *activity_full(selection.schedule)) \
        if selection.schedule.full?
    end
  end

  def activity_full(schedule)
    [:activity_full, { activity: schedule.name }]
  end
end
