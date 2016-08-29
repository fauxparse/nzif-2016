class CreateRelatedActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :related_activities do |t|
      t.belongs_to :parent
      t.belongs_to :child

      t.foreign_key :activities, column: :parent_id, on_delete: :cascade
      t.foreign_key :activities, column: :child_id, on_delete: :cascade
    end
  end
end
