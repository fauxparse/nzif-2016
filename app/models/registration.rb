class Registration < ApplicationRecord
  belongs_to :participant, -> { includes(:user) }
  belongs_to :festival
  belongs_to :package, optional: true
  has_many :selections, autosave: true, dependent: :destroy
  has_many :payments, dependent: :destroy

  validates :participant, :festival, presence: true
end
