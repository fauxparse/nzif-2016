class AddTokenToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :token, :string, limit: 64
    add_index :payments, :token, unique: true
  end
end
