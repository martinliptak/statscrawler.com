class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string     :name
      t.references :page
      t.references :location
      t.boolean    :ipv6
      t.datetime   :analyzed_at
    end
    add_index :domains, :name, :unique => true
    add_index :domains, :page_id
    add_index :domains, :location_id
  end
end
