class AddCompletionTimestampToRegistrations < ActiveRecord::Migration[5.0]
  def change
    change_table :registrations do |t|
      t.timestamp :completed_at
    end
  end
end
