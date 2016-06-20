class AddVenuesToSchedules < ActiveRecord::Migration[5.0]
  def change
    change_table :schedules do |t|
      t.belongs_to :venue, foreign_key: true
    end
  end
end
