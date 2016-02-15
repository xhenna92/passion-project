class CreateFoods < ActiveRecord::Migration
  def change
    create_table :foods do |t|
      t.string :name
      t.integer :duration_seconds

      t.timestamps null: false
    end
  end
end
