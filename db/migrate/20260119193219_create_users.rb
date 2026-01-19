class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :timezone, default: "America/Sao_Paulo", null: false
      t.boolean :weekly_summary_enabled, default: true, null: false
      t.boolean :reminders_enabled, default: true, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
