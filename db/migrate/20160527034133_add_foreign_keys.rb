class AddForeignKeys < ActiveRecord::Migration[5.0]
  def up
    change_column :registrations, :festival_id, :integer, null: false
    change_column :registrations, :participant_id, :integer, null: false
    add_foreign_key :participants, :users, on_delete: :nullify
    add_foreign_key :registrations, :festivals, on_delete: :cascade
    add_foreign_key :registrations, :participants, on_delete: :cascade
  end

  def down
    change_column :registrations, :festival_id, :integer, null: true
    change_column :registrations, :participant_id, :integer, null: true
    remove_foreign_key :participants, :users
    remove_foreign_key :registrations, :festivals
    remove_foreign_key :registrations, :participants
  end
end
