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
      :allocations => Activity.types.map(&:to_param)
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
  end

  def sanitize(params)
    return {} if params.blank? || params[:package].blank?
    params.require(:package).permit(self.class.parameters)
  end
end
