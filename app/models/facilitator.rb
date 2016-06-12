class Facilitator < ApplicationRecord
  belongs_to :participant
  belongs_to :activity

  acts_as_list scope: :activity_id, top_of_list: 0
end
