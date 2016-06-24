class Registration::Step::Package < Registration::Step
  delegate :package_id, to: :registration

  def complete?
    !package_selection_required? || package.present?
  end

  def packages
    festival.packages.ordered.includes(:prices, :allocations).map do |package|
      PackageSelection.new(package, registration)
    end
  end

  def self.parameters
    %i[package_id]
  end

  class PackageSelection
    include ActionView::Helpers::TextHelper

    def initialize(package, registration)
      @package = package
    end

    def price
      sorted_prices.detect(&:available?)
    end

    def description
      allocations.map { |allocation| allocation_description(allocation) }
        .compact.to_sentence.downcase
    end

    delegate :name, :id, :allocations, to: :package

    private

    attr_reader :package

    def sorted_prices
      @sorted_prices ||= package.prices.sort_by(&:expires_at)
    end

    def allocation_description(allocation)
      pluralize(allocation.maximum, allocation.activity_type.model_name.human) \
        if allocation.limited?
    end
  end

  private

  def package_selection_required?
    festival.packages.count > 1
  end
end
