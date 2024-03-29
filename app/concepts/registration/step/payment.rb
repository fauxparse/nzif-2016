class Registration::Step::Payment < Registration::Step
  attr_writer :amount, :payment_type

  def complete?
    registration.package.present? &&
    pending_payments_cover_deposit?
  end

  def payment_type
    @payment_type || ::Payment.payment_methods.first.key
  end

  def amount
    @amount || account.total_to_pay
  end

  def deposit_available?
    account.deposit < account.total_to_pay
  end

  def payment_methods
    ::Payment.payment_methods.map do |method|
      method.new(payment)
    end
  end

  def self.parameters
    %i[payment_type amount]
  end

  private

  def payment_service
    CreatePayment.new(
      registration,
      amount: amount,
      payment_type: payment_type
    )
  end

  def payment
    payment_service.payment
  end

  def apply_filtered_parameters(params)
    params.each { |key, value| send(:"#{key}=", value) }
    payment.valid?
  end

  def account
    @account ||= Account.new(registration)
  end

  def pending_payments_cover_deposit?
    account.total_pending_or_approved >= account.deposit
  end

  def continue
    payment_service
      .on(:success) { |payment| publish(:success, registration) }
      .on(:redirect) { |payment, url| publish(:redirect, url) }
      .call
  end
end
