class Selection < ApplicationRecord
  belongs_to :registration
  belongs_to :schedule, counter_cache: true

  validates :registration_id, :schedule_id, presence: true
  validates :schedule_id, uniqueness: { scope: :registration_id }

  validate :must_have_room_for_booking, if: :schedule_id_changed?

  private

  def must_have_room_for_booking
    errors.add(:schedule_id, :full) if schedule_id? && Schedule.find(schedule_id).full?
  end
end
