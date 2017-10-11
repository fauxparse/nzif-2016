class Comment < ApplicationRecord
  belongs_to :incident, counter_cache: true
  belongs_to :participant

  validates :participant, presence: true
end
