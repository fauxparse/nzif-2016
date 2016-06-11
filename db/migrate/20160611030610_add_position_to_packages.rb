class AddPositionToPackages < ActiveRecord::Migration[5.0]
  def change
    add_column :packages, :position, :integer, default: 0
  end
end
