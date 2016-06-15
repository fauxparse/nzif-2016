class CreateSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :schedules do |t|
      t.belongs_to :activity, required: true,
        foreign_key: { on_delete: :cascade }
      t.datetime :starts_at, required: true
      t.datetime :ends_at, required: true
      t.integer :position, default: 0

      t.index [:starts_at, :ends_at, :activity_id], unique: true
    end
  end
end
