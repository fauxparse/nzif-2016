class Registration < ApplicationRecord
  belongs_to :participant, -> { includes(:user) }
  belongs_to :festival
  belongs_to :package, optional: true

  validates :participant, :festival, presence: true
end
