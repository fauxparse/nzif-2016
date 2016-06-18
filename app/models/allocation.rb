class Allocation < ApplicationRecord
  belongs_to :package

  validates :package, presence: true
  validates :activity_type_name,
    presence: true,
    inclusion: { in: Activity.types.map(&:to_param) },
    uniqueness: { scope: :package_id, case_sensitive: false }
  validates :maximum,
    numericality: { greater_than_or_equal_to: 0, only_integer: true },
    if: :maximum?

  def name
    activity_type.model_name.human.pluralize.downcase
  end

  def allowed?
    maximum != 0
  end

  def unlimited?
    maximum.blank?
  end

  def accepts?(value)
    value >= 0 && (unlimited? || value <= maximum)
  end

  def activity_type
    Activity.type(activity_type_name) if activity_type_name?
  end

  def activity_type=(type)
    self.activity_type_name = type.try(:to_param)
  end
end
