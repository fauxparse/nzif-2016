class Festival < ApplicationRecord
  validates :year, :start_date, :end_date,
    presence: true

  validates :year, uniqueness: true

  scope :most_recent_first, -> { order(year: :desc) }

  def to_param
    year.to_s
  end
end
