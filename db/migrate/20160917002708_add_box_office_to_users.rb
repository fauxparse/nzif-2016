class AddBoxOfficeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :box_office, :boolean, default: false, index: true
  end
end
