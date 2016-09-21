class Account
  attr_reader :registration
  delegate :package, to: :registration

  def initialize(registration, as_at = Time.now)
    @registration = registration
    @as_at = as_at
  end

  def total
    applicable_package_price.try(&:amount)
  end

  def total_excluding_vouchers
    [Money.new(0), total - vouchers.map(&:amount).sum].max
  end

  def deposit
    applicable_package_price.deposit
  end

  def total_paid
    Money.new((approved_payments + vouchers).sum(&:amount))
  end

  def total_paid_by(type)
    Money.new(approved_payments_by(type).sum(&:amount))
  end

  def total_paid_by_internet_banking
    total_paid_by(:internet_banking)
  end

  def total_paid_by_paypal
    total_paid_by(:paypal)
  end

  def approved_payments_by(type)
    approved_payments.select { |payment| payment.payment_type.to_sym == type }
  end

  def total_paid_by_voucher
    Money.new(vouchers.sum(&:amount))
  end

  def total_paid_excluding_vouchers
    Money.new((approved_payments).sum(&:amount))
  end

  def total_paid_including_fees
    Money.new((approved_payments + vouchers).sum(&:total))
  end

  def total_pending
    Money.new(pending_payments.sum(&:amount))
  end

  def total_to_pay
    [total - total_paid, Money.new(0)].max
  end

  def paid_in_full?
    total_to_pay <= 0
  end

  def requires_additional_payment?
    total_pending_or_approved < total_to_pay
  end

  def total_pending_or_approved
    total_paid + total_pending
  end

  def applicable_package_price
    price_when_deposit_paid || price_with_next_expiry || full_package_price
  end

  def full_package_price
    prices.last
  end

  def earlybird_discount
    full_package_price.amount - applicable_package_price.amount
  end

  def earlybird_discount?
    earlybird_discount > 0
  end

  def payments
    if registration.payments.loaded?
      registration.payments.sort_by(&:created_at)
    else
      registration.payments.oldest_first
    end
  end

  def approved_payments
    payments.select(&:approved?)
  end

  def pending_payments
    payments.select(&:pending?)
  end

  def opened_on
    registration.created_at.to_date
  end

  def to_partial_path
    "account"
  end

  def outstanding_payment
    registration.payments.build(amount: total_to_pay)
  end

  def payment_methods
    Payment.payment_methods.map { |method| method.new(outstanding_payment) }
  end

  def vouchers
    @vouchers ||= Voucher.oldest_first.where(
      participant: registration.participant,
      festival: registration.festival
    ).all
  end

  private

  def prices
    @prices ||= if package.prices.loaded?
      package.prices.sort_by(&:expires_at)
    else
      package.prices.expiring_first
    end
  end

  def price_when_deposit_paid
    prices.detect do |price|
      deposit = approved_payments
        .select { |payment| payment.updated_at < price.expires_at }
        .sum(&:amount)
      deposit >= price.deposit
    end
  end

  def price_with_next_expiry
    prices.detect { |price| price.expires_at > @as_at }
  end
end
