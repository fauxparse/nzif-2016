class Venue < ApplicationRecord
  geocoded_by :address
  acts_as_list top_of_list: 0

  validates :name, :address, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  after_validation :geocode

  HOME = { latitude: -41.2935391, longitude: 174.784505 }.freeze

  scope :in_order, -> { order(:position) }
end
