class Schedule < ApplicationRecord
  belongs_to :activity
  has_many :selections, dependent: :destroy

  before_validation :set_end_time

  validates :starts_at, :ends_at, presence: true
  validates :maximum, numericality: { greater_than: 0, allow_blank: true }
  acts_as_list scope: [:starts_at, :ends_at], top_of_list: 0

  def timeslot
    (starts_at...ends_at)
  end

  def duration
    ends_at - starts_at
  end

  def limited?
    maximum.present?
  end

  def full?
    limited? && selections_count >= maximum
  end

  delegate :name, to: :activity

  private

  def set_end_time
    if starts_at.present? && ends_at.blank? && activity.present?
      self.ends_at = self.starts_at + activity.duration
    end
  end
end
