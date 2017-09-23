class Incident < ApplicationRecord
  belongs_to :festival
  belongs_to :participant, optional: true

  enum status: {
    open: 'open',
    closed: 'closed'
  }

  before_validation :anonymise, if: :anonymous?

  validates :description, presence: true
  validates :participant_id, absence: true, if: :anonymous?

  scope :anonymous, -> { where(participant_id: nil) }

  attr_accessor :anonymous

  def anonymous?
    !!anonymous
  end

  private

  def anonymise
    self.participant = nil
  end
end
