class AddGradesToActivities < ActiveRecord::Migration[5.0]
  def change
    add_column :activities, :grade, :string, limit: 16, default: 'unknown'
  end
end
