class CreateOrigins < ActiveRecord::Migration
  def change
    create_table :origins do |t|
      t.references :originable, polymorphic: true, index: true
      t.string :ip
      t.string :provider
      t.string :user_agent
      t.string :locale

      t.timestamps null: false
    end

    add_index :origins, [:originable_id, :originable_type], unique: true
  end
end
