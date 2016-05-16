class Registration < ApplicationRecord
  belongs_to :participant
  belongs_to :festival

  validates :participant, :festival, presence: true
end
