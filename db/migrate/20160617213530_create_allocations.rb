class CreateAllocations < ActiveRecord::Migration[5.0]
  def change
    create_table :allocations do |t|
      t.belongs_to :package, foreign_key: true
      t.string :activity_type_name, limit: 32, required: true
      t.integer :maximum, default: 0

      t.index [:package_id, :activity_type_name], unique: true
    end
  end
end
