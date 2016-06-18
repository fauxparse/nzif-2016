class Selection < ApplicationRecord
  belongs_to :registration
  belongs_to :schedule, counter_cache: true

  validates :registration_id, :schedule_id, presence: true
  validates :schedule_id, uniqueness: { scope: :registration_id }
end
