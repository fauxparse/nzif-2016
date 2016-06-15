class Schedule < ApplicationRecord
  belongs_to :activity

  before_validation :set_end_time

  validates :starts_at, :ends_at, presence: true
  acts_as_list scope: [:starts_at, :ends_at], top_of_list: 0

  def timeslot
    (starts_at...ends_at)
  end

  def duration
    ends_at - starts_at
  end

  delegate :name, to: :activity

  private

  def set_end_time
    if starts_at.present? && ends_at.blank? && activity.present?
      self.ends_at = self.starts_at + activity.duration
    end
  end
end
