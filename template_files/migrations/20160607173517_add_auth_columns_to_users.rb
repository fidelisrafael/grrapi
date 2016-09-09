class AddAuthColumnsToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :oauth_provider
      t.string :oauth_provider_uid
      t.string :activation_token

      t.datetime :activated_at
      t.datetime :activation_sent_at
      t.datetime :blocked_until

      t.json     :login_status_historic

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :password_reseted_at

      t.integer :login_attempts
    end

    add_index :users, :oauth_provider
    add_index :users, :oauth_provider_uid
    add_index :users, [:oauth_provider, :oauth_provider_uid], unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :activation_token, unique: true
  end
end
