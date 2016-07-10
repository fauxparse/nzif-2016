class Payment < ApplicationRecord
  belongs_to :registration
  has_one :participant, through: :registration

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

  scope :oldest_first, -> { order(:created_at) }
  scope :newest_first, -> { order(created_at: :desc) }

  def to_param
    "%.08d" % id
  end

  def payment_method
    payment_type.camelize.constantize.new
  end

  def payment_method=(method)
    self.payment_type = method.class.name.underscore
  end

  def approve!
    update!(status: :approved)
  end

  def decline!
    update!(status: :failed)
  end

  def cancel!
    update!(status: :cancelled)
  end

  def self.payment_methods
    [InternetBanking]
  end

  def self.with_registration_information
    includes(:registration => :participant)
  end

  private

  def valid_payment_method
    errors.add(:payment_method, :invalid) \
      unless payment_method.class.ancestors[1..-1].include?(PaymentMethod)
  end
end
