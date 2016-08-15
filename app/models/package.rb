class Package < ApplicationRecord
  belongs_to :festival
  has_many :allocations, autosave: true, dependent: :destroy
  has_many :prices, autosave: true, dependent: :destroy,
    :class_name => 'PackagePrice'

  acts_as_url :name, url_attribute: :slug, sync_url: true, scope: :festival_id
  acts_as_list scope: :festival, top_of_list: 0

  validates :name,
    presence: true,
    uniqueness: { scope: :festival_id, case_sensitive: false }
  validates_associated :allocations
  validate :at_least_one_price

  scope :ordered, -> { order(position: :asc) }
  scope :with_allocations, -> { includes(:allocations) }

  def to_param
    slug
  end

  def <=>(another)
    position <=> another.position
  end

  def total_count
    allocations.select(&:limited?).sum(&:maximum)
  end

  private

  def at_least_one_price
    errors.add(:base, :no_price) \
      unless prices.reject(&:marked_for_destruction?).any?
  end
end
