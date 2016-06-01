class AddPackageIdToRegistrations < ActiveRecord::Migration[5.0]
  def change
    change_table :registrations do |t|
      t.belongs_to :package, foreign_key: true
    end
  end
end
