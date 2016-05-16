class Festival < ApplicationRecord
  has_many :registrations, inverse_of: :festival, dependent: :destroy

  before_validation :fill_in_year, :unless => :year?

  validates :year, :start_date, :end_date,
    presence: true

  validates :year, uniqueness: true

  scope :most_recent_first, -> { order(year: :desc) }

  def to_param
    year.to_s
  end

  private

  def fill_in_year
    self.year ||= start_date.try(:year)
  end
end
