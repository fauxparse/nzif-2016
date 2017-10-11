class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.belongs_to :incident, foreign_key: { on_delete: :cascade }
      t.belongs_to :participant, foreign_key: { on_delete: :cascade }
      t.text :content

      t.timestamps

      t.index [:incident_id, :created_at]
    end

    change_table :incidents do |t|
      t.integer :comments_count, default: 0
    end
  end
end
