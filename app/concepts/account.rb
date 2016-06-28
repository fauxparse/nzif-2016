class Account
  attr_reader :registration

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
    approved_payments.sum(&:amount)
  end

  def total_to_pay
    total - total_paid
  end

  def total_pending_or_approved
    payments.select { |payment| payment.pending? || payment.approved? }
      .sum(&:amount)
  end

  def payments
    registration.payments.oldest_first
  end

  def approved_payments
    payments.select(&:approved?)
  end

  private

  def prices
    @prices ||= registration.package.prices.expiring_first
  end

  def applicable_package_price
    price_when_deposit_paid || price_with_next_expiry || prices.last
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
