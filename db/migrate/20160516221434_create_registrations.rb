class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :registrations do |t|
      t.belongs_to :participant, required: true
      t.belongs_to :festival, required: true

      t.timestamps
      t.index [:festival_id, :participant_id]
      t.index [:participant_id, :festival_id]
    end
  end
end
