class AddBioToParticipants < ActiveRecord::Migration[5.0]
  def change
    change_table :participants do |t|
      t.text :bio
    end
  end
end
