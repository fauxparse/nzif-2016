class Voucher < ApplicationRecord
  belongs_to :participant
  belongs_to :festival
  belongs_to :admin, class_name: "User", optional: true

  monetize :amount_cents

  validates :participant, :festival, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }

  scope :oldest_first, -> { order(:created_at) }

  def total
    amount
  end

  def granted_by
    admin.presence || festival
  end
end
