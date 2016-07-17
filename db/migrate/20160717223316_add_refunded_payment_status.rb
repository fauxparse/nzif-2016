class AddRefundedPaymentStatus < ActiveRecord::Migration[5.0]
  def up
    rebuild_status_column(%w(pending approved failed cancelled refunded))
  end

  def down
    Payment.where(status: :refunded).update_all(status: :cancelled)
    rebuild_status_column(%w(pending approved failed cancelled))
  end

  private

  def rebuild_status_column(values)
    execute <<~SQL
      ALTER TYPE payment_status RENAME TO old_payment_status;
      CREATE TYPE payment_status
        AS ENUM(#{values.map { |v| "'#{v}'" }.join(', ')});
      ALTER TABLE payments ALTER COLUMN status DROP DEFAULT;
      ALTER TABLE payments ALTER COLUMN status TYPE payment_status
        USING status::text::payment_status;
      ALTER TABLE payments ALTER COLUMN status
        SET DEFAULT 'pending'::payment_status;
      DROP TYPE old_payment_status;
    SQL
  end
end
