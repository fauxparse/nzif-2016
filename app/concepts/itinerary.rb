class Itinerary
  include ActiveModel::Validations
  validate :check_package_limits
  validate :check_activity_limits

  attr_reader :registration
  delegate :package, to: :registration

  def initialize(registration)
    @registration = registration
  end

  def selected?(schedule)
    selections.any? { |selection| selection.schedule_id == schedule.id }
  end

  def to_model
    registration
  end

  private

  def selections
    registration.selections
  end

  def selections_by_activity_type
    selections.group_by { |selection| selection.schedule.activity.class }
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
