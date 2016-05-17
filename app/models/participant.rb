class Participant < ApplicationRecord
  belongs_to :user, optional: true
  has_many :registrations, inverse_of: :participant, dependent: :destroy

  validates :name, presence: true
  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    unless: :user?
  validates :email,
    format: { with: Devise.email_regexp },
    if: :has_own_non_blank_email?

  def email
    user.try(:email) || super
  end

  def user?
    user.present?
  end

  private

  def has_own_non_blank_email?
    !read_attribute(:email).blank?
  end
end
