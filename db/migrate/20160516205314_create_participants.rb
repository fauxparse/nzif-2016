class CreateParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :participants do |t|
      t.belongs_to :user, null: true
      t.string :name
      t.string :email
      t.timestamps
    end
  end
end
