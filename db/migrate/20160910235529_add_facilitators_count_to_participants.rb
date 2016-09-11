class AddFacilitatorsCountToParticipants < ActiveRecord::Migration[5.0]
  def up
    add_column :participants, :facilitators_count, :integer, default: 0

    Participant.includes(:facilitators).all.each do |participant|
      participant.update!(facilitators_count: participant.facilitators.count)
    end
  end

  def down
    remove_column :participants, :facilitators_count
  end
end
