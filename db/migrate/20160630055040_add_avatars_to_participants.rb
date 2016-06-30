class AddAvatarsToParticipants < ActiveRecord::Migration[5.0]
  def change
    change_table :participants do |t|
      t.attachment :avatar
    end
  end
end
