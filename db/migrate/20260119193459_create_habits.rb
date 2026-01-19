class CreateHabits < ActiveRecord::Migration[7.0]
  def change
    create_table :habits do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false, limit: 60
      t.integer :goal_per_week, default: 7, null: false
      t.date :start_date, null: false
      t.datetime :archived_at
      t.string :color

      t.timestamps
    end

    add_index :habits, [:user_id, :archived_at]
  end
end
