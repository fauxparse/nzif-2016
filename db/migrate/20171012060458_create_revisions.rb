class CreateRevisions < ActiveRecord::Migration[5.1]
  def change
    create_table :revisions do |t|
      t.belongs_to :comment
      t.text :content
      t.timestamps
      t.index [:comment_id, :created_at]
    end

    change_table :comments do |t|
      t.integer :revisions_count, required: true, default: 0
    end
  end
end
