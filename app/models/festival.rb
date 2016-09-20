class Festival < ApplicationRecord
  has_many :registrations, dependent: :destroy
  has_many :packages, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :schedules, through: :activities
  has_many :payments, through: :registrations
  has_many :payment_configurations,
    class_name: 'PaymentMethod::Configuration::Base'
  has_many :vouchers, dependent: :destroy
  has_many :selections, through: :registrations

  before_validation :fill_in_year, :unless => :year?

  validates :year, :start_date, :end_date,
    presence: true

  validates :year, uniqueness: true

  scope :most_recent_first, -> { order(year: :desc) }
  scope :with_schedule, -> { includes(:activities => :schedules) }

  def to_param
    year.to_s
  end

  def name
    I18n.t('festival.name', year: year)
  end

  def to_s
    name
  end

  def self.most_recent
    most_recent_first.first
  end

  private

  def fill_in_year
    self.year ||= start_date.try(:year)
  end
end
