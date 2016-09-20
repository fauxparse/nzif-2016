require 'pleasant_lawyer'

class Registration < ApplicationRecord
  belongs_to :participant, -> { includes(:user) }
  belongs_to :festival
  belongs_to :package, optional: true
  has_many :selections, autosave: true, dependent: :destroy
  has_many :payments, dependent: :destroy

  validates :participant, :festival, presence: true
  validates :festival_id, uniqueness: { scope: :participant_id }

  scope :complete, -> { where.not(completed_at: nil) }

  def to_param
    PleasantLawyer.convert(id).join('-')
  end

  def code_of_conduct_accepted?
    code_of_conduct_accepted_at.present?
  end

  def complete?
    completed_at.present?
  end

  def self.find_by_pleasant_lawyer(id)
    find(PleasantLawyer.convert(id.tr('-', ' ')))
  end
end
