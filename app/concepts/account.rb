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

  def deposit
    applicable_package_price.deposit
  end

  def total_paid
    Money.new(approved_payments.sum(&:amount))
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
    registration.payments.oldest_first
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

  private

  def prices
    @prices ||= package.prices.expiring_first
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
