class Registration::Step::Activities < Registration::Step
  include ActionView::Helpers::TextHelper

  delegate :package_id, to: :registration
  delegate :full_schedules, to: :itinerary

  def complete?
    !package_selection_required? || package.present?
  end

  def self.parameters
    [:package_id, { :selections => [] }]
  end

  def itinerary
    @itinerary ||= Itinerary.new(registration)
  end

  def as_json(options = {})
    ActiveModelSerializers::SerializableResource.new(itinerary, full: true)
      .as_json
  end

  def maximum_allocation
    largest_package.allocations.select(&:limited?)
      .map(&method(:describe_allocation))
      .to_sentence
  end

  private

  def apply_filtered_parameters(params)
    itinerary.update(params)
    itinerary.full_schedules.each do |schedule|
      errors.add(
        :base,
        I18n.t(
          :activity_full,
          activity: schedule.name,
          scope: 'activemodel.errors.models.itinerary.attributes.base'
        )
      )
    end
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
end
