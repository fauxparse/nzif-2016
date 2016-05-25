class Registration < ApplicationRecord
  belongs_to :participant, -> { includes(:user) }
  belongs_to :festival

  validates :participant, :festival, presence: true
end
