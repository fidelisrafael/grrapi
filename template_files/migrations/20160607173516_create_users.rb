class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :username
      t.string :password_digest
      t.string :profile_type
      t.string :profile_image
      t.datetime :tof_accepted_at

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :profile_type
  end
end
