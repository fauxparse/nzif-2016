class CreateFestivals < ActiveRecord::Migration[5.0]
  def change
    create_table :festivals do |t|
      t.integer :year, required: true, index: true
      t.date :start_date, required: true
      t.date :end_date, required: true
      t.timestamps
    end
  end
end
