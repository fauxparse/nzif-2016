class CreatePayment
  include Cry
  attr_accessor :registration, :payment

  def initialize(registration, attributes = {})
    @registration = registration
    @payment ||= registration.payments.build(attributes)
  end

  def call
    if payment.save
      payment.payment_method
        .on(:success, &method(:payment_created))
        .on(:redirect) { |url| publish(:redirect, payment, url) }
        .created
    else
      publish(:failure, payment)
    end
  end

  private

  def payment_created(payment)
    # TODO: creation of the first payment completes registration
    publish(:success, payment)
  end
end
