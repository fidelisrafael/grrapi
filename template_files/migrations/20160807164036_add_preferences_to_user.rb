class AddPreferencesToUser < ActiveRecord::Migration
  def up
    ActiveRecord::Schema.define do
      enable_extension 'hstore' unless extension_enabled?('hstore')

      change_table :users do |t|
        t.hstore 'preferences'
      end
    end

    User.with_deleted.find_each do |user|
      user.create_default_preferences
    end
  end

  def down
    remove_column :users, :preferences
  end
end
