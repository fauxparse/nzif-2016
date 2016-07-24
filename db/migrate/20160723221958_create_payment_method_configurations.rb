class CreatePaymentMethodConfigurations < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_method_configurations do |t|
      t.belongs_to :festival, foreign_key: { on_delete: :cascade }
      t.string :type, limit: 64, required: true
      t.text :configuration, required: true, default: '{}'

      t.index [:festival_id, :type], unique: true
    end
  end
end
