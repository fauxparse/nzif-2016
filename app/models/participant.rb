class Participant < ApplicationRecord
  belongs_to :user, optional: true
  has_many :registrations, dependent: :destroy
  has_many :facilitators, dependent: :destroy
  has_many :vouchers, dependent: :destroy

  has_attached_file :avatar, styles: {
    small:  ['64x64#',   :jpg],
    medium: ['128x128#', :jpg],
    large:  ['256x256#', :jpg]
  }

  validates :name, presence: true
  validates :email,
    presence: true,
    unless: :user_email_present?
  validates :email,
    format: { with: Devise.email_regexp },
    uniqueness: { case_sensitive: false },
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

  def <=>(another)
    name <=> another.name
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

  def user_email_present?
    user? && !user.email.blank?
  end
end
