class Package < ApplicationRecord
  belongs_to :festival

  acts_as_url :name, url_attribute: :slug, sync_url: true
  acts_as_list scope: :festival, top_of_list: 0

  validates :name,
    presence: true,
    uniqueness: { scope: :festival_id, case_sensitive: false }

  scope :ordered, -> { order(position: :asc) }

  def <=>(another)
    position <=> another.position
  end
end
