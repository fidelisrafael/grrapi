class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :city, index: true, foreign_key: true
      t.references :addressable, polymorphic: true, index: true
      t.string :street
      t.string :number
      t.string :district
      t.string :complement
      t.string :zipcode

      t.timestamps null: false
    end
    add_index :addresses, :street
  end
end
