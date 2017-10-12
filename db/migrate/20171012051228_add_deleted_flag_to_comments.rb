class AddDeletedFlagToComments < ActiveRecord::Migration[5.1]
  def change
    change_table :comments do |t|
      t.boolean :deleted, required: true, default: false

      t.remove_index [:incident_id, :created_at]
      t.index [:incident_id, :deleted, :created_at]
    end
  end
end
