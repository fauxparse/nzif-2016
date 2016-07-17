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

  serialize :transaction_data, HashWithIndifferentAccess

  before_validation :generate_random_token

  validates :registration_id, :status, :amount, :payment_method, :token,
    presence: true
  validates :amount_cents, numericality: { greater_than: 0 }
  validate :valid_payment_method, if: :payment_type?
  validates :token, format: { with: /\A[0-9a-f]{32}\z/ }

  scope :oldest_first, -> { order(:created_at) }
  scope :newest_first, -> { order(created_at: :desc) }

  def to_param
    token
  end

  def reference
    "%08d" % id
  end

  def payment_method
    PaymentMethod.const_get(payment_type.camelize).new
  end

  def payment_method=(method)
    self.payment_type = method.class.key
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
    [PaymentMethod::Paypal, PaymentMethod::InternetBanking]
  end

  def self.with_registration_information
    includes(:registration => :participant)
  end

  private

  def valid_payment_method
    errors.add(:payment_method, :invalid) \
      unless payment_method.class.ancestors[1..-1].include?(PaymentMethod)
  end

  def generate_random_token
    while !token? || self.class.where.not(id: id).exists?(token: token)
      self.token = SecureRandom.hex(16)
    end
  end
end
