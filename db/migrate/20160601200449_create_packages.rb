class CreatePackages < ActiveRecord::Migration[5.0]
  def change
    create_table :packages do |t|
      t.belongs_to :festival, foreign_key: true
      t.string :name
      t.string :slug, limit: 128

      t.timestamps
    end
  end
end
