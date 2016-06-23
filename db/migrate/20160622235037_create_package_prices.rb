class CreatePackagePrices < ActiveRecord::Migration[5.0]
  def change
    create_table :package_prices do |t|
      t.belongs_to :package
      t.datetime :expires_at
      t.monetize :amount
      t.monetize :deposit

      t.index [:package_id, :expires_at], unique: true
    end
  end
end
