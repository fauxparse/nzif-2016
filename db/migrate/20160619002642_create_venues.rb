class CreateVenues < ActiveRecord::Migration[5.0]
  def change
    create_table :venues do |t|
      t.string :name, required: true
      t.string :address, required: true
      t.decimal :latitude, precision: 9, scale: 6, required: true
      t.decimal :longitude, precision: 9, scale: 6, required: true
      t.integer :position
    end
  end
end
