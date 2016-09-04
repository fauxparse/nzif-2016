class CreateVouchers < ActiveRecord::Migration[5.0]
  def change
    create_table :vouchers do |t|
      t.belongs_to :admin, required: false,
        foreign_key: { to_table: :users, on_delete: :nullify }
      t.belongs_to :participant, required: true,
        foreign_key: { on_delete: :cascade }
      t.belongs_to :festival, required: true,
        foreign_key: { on_delete: :cascade }
      t.monetize :amount, required: true
      t.string :reason, limit: 128
      t.timestamps

      t.index [:festival_id, :participant_id]
    end
  end
end
