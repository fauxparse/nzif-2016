class CreateSelections < ActiveRecord::Migration[5.0]
  def change
    create_table :selections do |t|
      t.belongs_to :registration, foreign_key: true
      t.belongs_to :schedule, foreign_key: true
      t.timestamps
      t.index [:registration_id, :schedule_id], unique: true
    end
  end
end
