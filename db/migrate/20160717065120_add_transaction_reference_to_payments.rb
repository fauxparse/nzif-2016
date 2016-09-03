class AddTransactionReferenceToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :transaction_reference, :string, limit: 32
  end
end
