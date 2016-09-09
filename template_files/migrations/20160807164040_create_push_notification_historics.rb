class CreatePushNotificationHistorics < ActiveRecord::Migration
  def change
    create_table :push_notification_historics do |t|
      t.integer :receiver_user_id
      t.integer :sender_user_id
      t.integer :notificable_id
      t.string :notificable_type
      t.string :notification_type
      t.string :message
      t.json :metadata
      t.datetime :delivered_at

      t.timestamps null: false
    end
    add_index :push_notification_historics, :receiver_user_id
    add_index :push_notification_historics, :sender_user_id
    add_index :push_notification_historics, :notificable_id
    add_index :push_notification_historics, :notificable_type
    add_index :push_notification_historics, :notification_type
  end
end
