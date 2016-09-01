class PaymentConfigurationForm
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :festival

  def initialize(festival, params = {})
    @festival = festival
    params = sanitize(params)
    apply(params) unless params.empty?
  end

  def persisted?
    true
  end

  def save
    PaymentMethod::Configuration::Base.transaction do
      valid? && configurations.all?(&:save!)
    end
  rescue ActiveRecord::RecordInvalid
    return false
  end

  def valid?
    configurations.all?(&:valid?)
  end

  def configurations
    @configurations ||= self.class.configuration_classes.map do |klass|
      festival.payment_configurations.detect { |config| config.is_a?(klass) } ||
        festival.payment_configurations.build.becomes!(klass)
    end
  end

  def self.allowed_attributes
    configuration_classes.each.with_object({}) do |configuration, attrs|
      attrs[configuration.key] = configuration.configuration_attributes
    end
  end

  private

  def sanitize(params)
    return {} if params.blank? || params[:payment_configuration].blank?
    params.require(:payment_configuration).permit(self.class.allowed_attributes)
  end

  def apply(params)
    params.each do |key, attrs|
      config = configuration_for(key)
      attrs.each { |attr, value| config.send :"#{attr}=", value }
    end
  end

  def self.configuration_classes
    Payment.payment_methods.map(&:configuration_class)
  end

  def configuration_for(payment_method)
    configurations.detect { |config| config.key == payment_method.to_sym }
  end
end
