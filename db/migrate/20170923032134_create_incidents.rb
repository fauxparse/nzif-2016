class CreateIncidents < ActiveRecord::Migration[5.1]
  def change
    create_table :incidents do |t|
      t.belongs_to :festival, foreign_key: { on_delete: :cascade }
      t.belongs_to :participant, required: false
      t.text :description
      t.string :status, limit: 32, required: true, default: 'open'

      t.timestamps
    end
  end
end
