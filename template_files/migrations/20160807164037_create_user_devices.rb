class CreateUserDevices < ActiveRecord::Migration
  def change
    create_table :user_devices do |t|
      t.references :user, index: true, foreign_key: true
      t.string :identifier
      t.string :token
      t.string :platform
      t.datetime :deleted_at
      t.string :parse_object_id
      t.string :parse_installation_id
      t.string :installation_id

      t.timestamps null: false
    end
    add_index :user_devices, :token
    add_index :user_devices, :deleted_at
    add_index :user_devices, [:parse_object_id], unique: true
    add_index :user_devices, [:parse_object_id, :token], unique: true
  end
end
