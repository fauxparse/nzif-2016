class Package < ApplicationRecord
  belongs_to :festival

  acts_as_url :name, url_attribute: :slug, sync_url: true

  validates :name,
    presence: true,
    uniqueness: { scope: :festival_id, case_sensitive: false }
end
