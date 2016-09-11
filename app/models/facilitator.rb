class Facilitator < ApplicationRecord
  belongs_to :participant, counter_cache: true
  belongs_to :activity

  acts_as_list scope: :activity_id, top_of_list: 0

  def to_s
    participant.name.dup.tap do |name|
      name << " (#{participant.origin})" if participant.origin?
    end
  end

  def self.with_workshop_rolls(festival)
    includes(
      :activity => {
        :schedules => {
          :selections => {
            :registration => :participant
          }
        }
      }
    )
      .references(:activities)
      .where(
        'activities.festival_id = ? && activities.type = ?',
        festival.id,
        'Workshop'
      )
  end
end
