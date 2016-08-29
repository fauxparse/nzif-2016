class RelatedActivity < ApplicationRecord
  belongs_to :parent, class_name: 'Activity'
  belongs_to :child, class_name: 'Activity'

  validates :parent, :child, presence: true
  validates :child_id, uniqueness: { scope: :parent_id }
end
