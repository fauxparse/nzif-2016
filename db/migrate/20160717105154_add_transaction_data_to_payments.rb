class AddTransactionDataToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :transaction_data, :text, default: "{}"
  end
end
