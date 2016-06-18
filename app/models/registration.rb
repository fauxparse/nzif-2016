class Registration < ApplicationRecord
  belongs_to :participant, -> { includes(:user) }
  belongs_to :festival
  belongs_to :package, optional: true
  has_many :selections, autosave: true, dependent: :destroy

  validates :participant, :festival, presence: true
end
