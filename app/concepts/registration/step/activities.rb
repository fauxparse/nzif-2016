class Registration::Step::Activities < Registration::Step
  include ActionView::Helpers::TextHelper

  delegate :package_id, to: :registration

  def complete?
    !package_selection_required? || package.present?
  end

  def self.parameters
    [:package_id, { :selections => [] }]
  end

  def as_json(options = {})
    {
      activities: schedules_as_json,
      packages: packages_as_json,
      allocations: allocations_as_json
    }
  end

  def maximum_allocation
    largest_package.allocations.select(&:limited?)
      .map(&method(:describe_allocation))
      .to_sentence
  end

  private

  def apply_filtered_parameters(params)
    Itinerary.new(registration).update(params)
  end

  def describe_allocation(allocation)
    pluralize(
      allocation.maximum,
      allocation.activity_type.model_name.human.downcase
    )
  end

  def largest_package
    @largest ||= festival.packages.max_by(&:total_count)
  end

  def package_selection_required?
    festival.packages.count > 1
  end

  def packages_as_json
    ActiveModelSerializers::SerializableResource.new(festival.packages).as_json
  end

  def limited_types
    @limited_types ||= largest_package.allocations
      .select(&:limited?).map(&:activity_type)
  end

  def schedules
    festival.schedules.with_activity_details
      .references(:activities)
      .where('activities.type IN (?)', limited_types)
  end

  def schedules_as_json
    schedules.map(&method(:serialize_schedule))
  end

  def serialize_schedule(schedule)
    ActiveModelSerializers::SerializableResource.new(schedule)
      .as_json
      .merge(selected: selected?(schedule))
  end

  def selected?(schedule)
    registration.selections.any? { |s| s.schedule_id == schedule.id }
  end

  def allocations_as_json
    ActiveModelSerializers::SerializableResource
      .new(largest_package.allocations).as_json
  end
end
