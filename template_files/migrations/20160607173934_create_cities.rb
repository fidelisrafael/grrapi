class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.references :state, index: true, foreign_key: true
      t.string :name

      t.timestamps null: false
    end

    add_index :cities, [:state_id, :name], unique: true
  end
end
