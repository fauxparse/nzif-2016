class AddDetailsToParticipants < ActiveRecord::Migration[5.0]
  def change
    change_table :participants do |t|
      t.string :origin, limit: 128
      t.string :company, limit: 128
    end
  end
end
