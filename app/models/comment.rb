class Comment < ApplicationRecord
  belongs_to :incident, counter_cache: true
  belongs_to :participant
  has_one :festival, through: :incident

  validates :participant, presence: true

  scope :not_deleted, -> { where(deleted: false) }
  scope :oldest_first, -> { order(:created_at) }

  def mark_as_deleted!
    update!(deleted: true)
  end
end
