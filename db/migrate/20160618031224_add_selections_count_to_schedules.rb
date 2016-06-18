class AddSelectionsCountToSchedules < ActiveRecord::Migration[5.0]
  def change
    add_column :schedules, :selections_count, :integer, default: 0
  end
end
