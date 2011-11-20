class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :ip
      t.string :country
      t.string :city
      t.float :longitude
      t.float :latitude
    end

    add_index :locations, :ip, :unique => true
    add_index :locations, [:country, :id]
    add_index :locations, [:city, :id]
    add_index :locations, [:longitude, :latitude, :city, :id]
  end
end
