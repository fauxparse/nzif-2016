class Registration::Step::Payment < Registration::Step
  def complete?
    registration.package.present? &&
    pending_payments_cover_deposit?
  end

  def payment_type
    payment.payment_type || ::Payment.payment_methods.first.key
  end

  def amount
    payment.amount
  end

  def self.parameters
    %i[payment_type amount]
  end

  private

  def payment
    @payment ||= registration.payments.build(amount: account.total_to_pay)
  end

  def apply_filtered_parameters(params)
    payment.attributes = params
    payment.save
  end

  def account
    @account ||= Account.new(registration)
  end

  def pending_payments_cover_deposit?
    account.total_pending_or_approved > account.deposit
  end

  def continue
    payment.payment_method
      .on(:success) { |payment| publish(:success, registration) }
      .on(:redirect) { |url| publish(:redirect, url) }
      .created(payment)
  end
end
