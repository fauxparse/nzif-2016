class Activity < ApplicationRecord
  belongs_to :festival
  has_many :facilitators, dependent: :destroy, autosave: true
  has_many :schedules, dependent: :destroy, autosave: true

  acts_as_url :name, url_attribute: :slug, sync_url: true, scope: :festival_id

  has_attached_file :image, styles: {
    small:  ['320x180#',  :jpg],
    medium: ['640x360#',  :jpg],
    large:  ['1280x720#', :jpg]
  }

  enum :grade => {
    advanced:     'advanced',
    experienced:  'experienced',
    intermediate: 'intermediate',
    open:         'open',
    unknown:      'unknown'
  }

  validates :name,
    presence: true,
    uniqueness: { scope: [:festival_id, :type], case_sensitive: false }
  validates_attachment_content_type :image, :content_type => %w(image/jpeg image/jpg image/png)

  scope :alphabetically, -> { order(name: :asc) }

  def to_param
    slug
  end

  def self.types
    [Workshop, Show, SocialEvent, Discussion]
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
