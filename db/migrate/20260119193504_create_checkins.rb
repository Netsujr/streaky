class CreateCheckins < ActiveRecord::Migration[7.0]
  def change
    create_table :checkins do |t|
      t.references :habit, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :occurred_on, null: false

      t.timestamps
    end

    add_index :checkins, [:user_id, :occurred_on]
    add_index :checkins, [:habit_id, :occurred_on], unique: true
  end
end
