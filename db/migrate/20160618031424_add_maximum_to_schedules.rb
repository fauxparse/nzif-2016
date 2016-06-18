class AddMaximumToSchedules < ActiveRecord::Migration[5.0]
  def change
    add_column :schedules, :maximum, :integer
  end
end
