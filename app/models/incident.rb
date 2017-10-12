class Incident < ApplicationRecord
  belongs_to :festival
  belongs_to :participant, optional: true
  has_many :comments, dependent: :destroy
  has_one :latest_comment,
    -> { order(created_at: :desc).merge(Comment.not_deleted) },
    class_name: 'Comment'

  enum status: {
    open: 'open',
    closed: 'closed'
  }

  before_validation :anonymise, if: :anonymous?

  validates :description, presence: true
  validates :participant_id, absence: true, if: :anonymous?

  scope :anonymous, -> { where(participant_id: nil) }
  scope :newest_first, -> { order(created_at: :desc) }

  attr_accessor :anonymous

  def anonymous?
    if anonymous.nil?
      participant.blank?
    else
      anonymous
    end
  end

  private

  def anonymise
    self.participant = nil
  end
end
