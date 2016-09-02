class AddFeesToPayments < ActiveRecord::Migration[5.0]
  def change
    change_table :payments do |t|
      t.monetize :fee, required: true, default: 0
    end
  end
end
