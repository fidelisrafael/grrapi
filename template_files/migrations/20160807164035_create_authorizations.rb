class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.references :user, index: true, on_delete: :cascade, foreign_key: true
      t.string :token
      t.string :provider
      t.datetime :expires_at

      t.timestamps null: false
    end

    add_index :authorizations, :token
    add_index :authorizations, :provider

    add_index :authorizations, [:user_id, :token, :provider], unique: true
  end
end
