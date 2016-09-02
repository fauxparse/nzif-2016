class PaymentMethod::Base
  include Cry
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  attr_reader :payment

  def initialize(payment)
    @payment = payment
  end

  def created
    publish(:success, payment)
  end

  def configuration
    @configuration ||= self.class.configuration_class
      .find_or_initialize_by(festival: festival)
  end

  def fee
    Money.new(configuration.transaction_fee.to_i * 100, payment.amount.currency)
  end

  def key
    self.class.key
  end

  def self.key
    name.demodulize.underscore
  end

  def self.configuration_keys
    []
  end

  def self.configuration_class
    PaymentMethod::Configuration.const_get(name.demodulize + 'Configuration')
  end

  private

  def festival
    payment.festival
  end
end
