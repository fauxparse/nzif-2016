class CreatePayments < ActiveRecord::Migration[5.0]
  def up
    execute <<~SQL
      CREATE TYPE payment_status
        AS ENUM('pending', 'approved', 'failed', 'cancelled');
    SQL

    create_table :payments do |t|
      t.belongs_to :registration, foreign_key: { on_delete: :cascade }
      t.column :status, :payment_status, required: true, default: 'pending', index: true
      t.string :payment_type, required: true, index: true
      t.monetize :amount, required: true
      t.string :reference, limit: 32
      t.string :failure_message, limit: 128
      t.timestamps
    end

    add_index :payments, [:registration_id, :status]
  end

  def down
    drop_table :payments

    execute <<~SQL
      DROP TYPE payment_status;
    SQL
  end
end
