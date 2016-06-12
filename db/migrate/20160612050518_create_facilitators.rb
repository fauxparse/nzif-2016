class CreateFacilitators < ActiveRecord::Migration[5.0]
  def change
    create_table :facilitators do |t|
      t.belongs_to :participant, foreign_key: true
      t.belongs_to :activity, foreign_key: true
      t.integer :position, default: 0
    end
  end
end
