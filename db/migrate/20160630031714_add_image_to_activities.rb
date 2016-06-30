class AddImageToActivities < ActiveRecord::Migration[5.0]
  def change
    change_table :activities do |t|
      t.attachment :image
    end
  end
end
