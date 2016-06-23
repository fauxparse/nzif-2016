class PackageForm
  include ActiveModel::Validations

  attr_reader :package
  delegate :valid?, :errors, :save, to: :package

  def initialize(package, params = nil)
    @package = package
    apply(sanitize(params))
  end

  def name
    package.name
  end

  def name=(value)
    package.name = value
  end

  def prices
    package.prices.build(expires_at: package.festival.end_date.succ.midnight) \
      if package.prices.empty?
    package.prices.sort_by(&:expires_at)
  end

  def prices=(prices)
    package.prices.build while package.prices.size < prices.size
    package.prices.zip(prices).each do |package_price, (price, deposit, expiry)|
      if price.nil?
        package_price.mark_for_destruction
      else
        package_price.amount = price
        package_price.deposit = deposit
        package_price.expires_at = Time.zone.parse(expiry) + 1.day
      end
    end
  end

  def allocations
    Activity.types.each.with_object({}) do |type, limits|
      limits[type.to_param] = allocation_by_type(type).maximum
    end
  end

  def allocations=(limits)
    Activity.types.each do |type|
      limit = allocation_by_type(type)
      limit.maximum = limits.key?(type.to_param) ? limits[type.to_param] : nil
    end
  end

  def to_model
    package
  end

  def self.parameters
    [
      :name,
      :allocations => Activity.types.map(&:to_param),
      :prices => [],
      :deposits => [],
      :expiries => []
    ]
  end

  private

  def allocation_by_type(type)
    limit = package.allocations.detect do |allocation|
      allocation.activity_type == type
    end || package.allocations.build(activity_type: type, maximum: 0)
  end

  def apply(params)
    return if params.blank?
    @package.name = params[:name]
    self.allocations = params[:allocations] if params[:allocations].present?
    self.prices = params[:prices].zip(params[:deposits], params[:expiries]) \
      if params[:prices].present?
  end

  def sanitize(params)
    return {} if params.blank? || params[:package].blank?
    params.require(:package).permit(self.class.parameters)
  end
end
