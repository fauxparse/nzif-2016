class Activity < ApplicationRecord
  belongs_to :festival
  has_many :facilitators, dependent: :destroy, autosave: true
  has_many :schedules, dependent: :destroy, autosave: true

  acts_as_url :name, url_attribute: :slug, sync_url: true, scope: :festival_id

  validates :name,
    presence: true,
    uniqueness: { scope: :festival_id, case_sensitive: false }

  scope :alphabetically, -> { order(name: :asc) }

  def to_param
    slug
  end

  def self.types
    [Workshop, Show, SocialEvent]
  end

  def self.type(name = nil)
    types.detect { |type| type.to_param == name } || types.first
  end

  def self.to_param
    name.underscore.pluralize
  end

  def self.by_type(type)
    type = types.first if type.blank?
    type = type.name if type.respond_to?(:name)
    where(type: type.singularize.camelize)
  end
end
