class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :name, unique: true
      t.string :acronym, unique: true

      t.timestamps null: false
    end
  end
end
