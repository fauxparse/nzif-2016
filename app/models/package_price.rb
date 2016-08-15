class PackagePrice < ApplicationRecord
  belongs_to :package, inverse_of: :prices

  monetize :amount_cents
  monetize :deposit_cents
  before_validation :set_default_expiry

  validates :package, :expires_at, presence: true

  validates :amount_cents,
    presence: true,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0
    }

  validates :deposit_cents,
    numericality: {
      only_integer: true,
      greater_than_or_equal_to: 0,
      allow_blank: true
    }

  scope :expiring_first, -> { order(:expires_at) }
  scope :available_at, ->(time = Time.now) {
    expiring_first.where('expires_at > ?', time)
  }

  def available?
    available_at?(Time.now)
  end

  def available_at?(time)
    expires_at > time
  end

  def self.current
    available_at(Time.now).first
  end

  private

  def set_default_expiry
    self.expires_at = package.festival.end_date.succ.midnight unless expires_at?
  end
end
