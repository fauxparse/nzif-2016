class Payment < ApplicationRecord
  belongs_to :registration

  enum status: {
    pending:   'pending',
    approved:  'approved',
    failed:    'failed',
    cancelled: 'cancelled'
  }

  monetize :amount_cents

  validates :registration_id, :status, :amount, :payment_method,
    presence: true
  validates :amount_cents, numericality: { greater_than: 0 }
  validate :valid_payment_method, if: :payment_type?

  scope :oldest_first, -> { order(:updated_at) }

  def payment_method
    payment_type.camelize.constantize.new
  end

  def payment_method=(method)
    self.payment_type = method.class.name.underscore
  end

  def approve!
    update(status: :approved)
  end

  def self.payment_methods
    [InternetBanking]
  end

  private

  def valid_payment_method
    errors.add(:payment_method, :invalid) \
      unless payment_method.class.ancestors[1..-1].include?(PaymentMethod)
  end
end
