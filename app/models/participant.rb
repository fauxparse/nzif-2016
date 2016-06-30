class Participant < ApplicationRecord
  belongs_to :user, optional: true
  has_many :registrations, dependent: :destroy
  has_many :facilitators, dependent: :destroy

  has_attached_file :avatar, styles: {
    small:  ['64x64#',   :jpg],
    medium: ['128x128#', :jpg],
    large:  ['256x256#', :jpg]
  }

  validates :name, presence: true
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    unless: :user?
  validates :email,
    format: { with: Devise.email_regexp },
    if: :has_own_non_blank_email?
  validates_attachment_content_type :avatar, :content_type => %w(image/jpeg image/jpg image/png)

  def email
    [user.try(:email), super].reject(&:blank?).first
  end

  def user?
    user.present?
  end

  def to_s
    name
  end

  def self.with_user
    includes(:user)
  end

  def self.by_name
    order(name: :asc)
  end

  private

  def has_own_non_blank_email?
    !read_attribute(:email).blank?
  end
end
