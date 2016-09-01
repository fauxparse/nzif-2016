class AddCodeOfConductToRegistrations < ActiveRecord::Migration[5.0]
  def change
    change_table :registrations do |t|
      t.timestamp :code_of_conduct_accepted_at
    end
  end
end
