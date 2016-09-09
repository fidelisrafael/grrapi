class ChangeUniqueIndexesInUsers < ActiveRecord::Migration
  def up
    remove_index :users, :email
    remove_index :users, :username
    remove_index :users, [:oauth_provider, :oauth_provider_uid]

    add_index :users, :email, where: 'deleted_at IS NULL', unique: true
    add_index :users, :username, where: 'deleted_at IS NULL', unique: true
    add_index :users, [:oauth_provider, :oauth_provider_uid], where: 'deleted_at IS NULL', unique: true
  end

  def down
    remove_index :users, :email
    remove_index :users, :username
    remove_index :users, [:oauth_provider, :oauth_provider_uid]

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, [:oauth_provider, :oauth_provider_uid], unique: true
  end
end
