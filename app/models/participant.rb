class Participant < ApplicationRecord
  belongs_to :user, optional: true

  validates :name, :email, presence: true
  validates :email,
    uniqueness: { case_sensitive: false },
    format: { with: Devise.email_regexp },
    unless: :user_id?

  def email
    super || user.try(:email)
  end
end
