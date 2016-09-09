class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :notificable_id
      t.string :notificable_type
      t.integer :receiver_user_id
      t.integer :sender_user_id
      t.string :notification_type
      t.datetime :read_at

      t.timestamps null: false
    end
    add_index :notifications, [:notificable_id,:notificable_type]
    add_index :notifications, :receiver_user_id
    add_index :notifications, :sender_user_id
    add_index :notifications, :read_at
  end
end
