class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.string :type
      t.belongs_to :festival, foreign_key: true
      t.string :name
      t.string :slug
      t.text :description

      t.timestamps
    end
  end
end
