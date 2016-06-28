class CreateModelAs < ActiveRecord::Migration
  def change
    create_table :model_as do |t|
      t.string :a
      t.integer :b
      t.float :c
      t.boolean :d
      t.date :e

      t.timestamps null: false
    end
  end
end
