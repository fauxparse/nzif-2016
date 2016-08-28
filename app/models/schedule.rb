class Schedule < ApplicationRecord
  belongs_to :activity
  belongs_to :venue, optional: true
  has_many :selections, dependent: :destroy

  acts_as_list scope: [:starts_at, :ends_at], top_of_list: 0

  before_validation :set_end_time

  validates :starts_at, :ends_at, presence: true
  validates :maximum, numericality: { greater_than: 0, allow_blank: true }
  validates :venue_id,
    uniqueness: { scope: [:starts_at, :ends_at] },
    if: :venue_id?

  scope :in_order, -> { order(:starts_at, :position) }
  scope :with_activity_information, -> {
    includes(:activity => { :facilitators => :participant })
  }

  def timeslot
    (starts_at...ends_at)
  end

  def duration
    ends_at - starts_at
  end

  def date
    starts_at.to_date
  end

  def limited?
    maximum.present?
  end

  def full?
    limited? && selections_count >= maximum
  end

  def <=>(another)
    if starts_at == another.starts_at
      position <=> another.position
    else
      starts_at <=> another.starts_at
    end
  end

  delegate :name, to: :activity

  def self.with_activity_details
    includes(:venue, :activity => { :facilitators => :participant })
  end

  private

  def set_end_time
    if starts_at.present? && ends_at.blank? && activity.present?
      self.ends_at = self.starts_at + activity.duration
    end
  end
end
