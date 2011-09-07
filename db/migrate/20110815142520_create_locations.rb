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
  end
end
