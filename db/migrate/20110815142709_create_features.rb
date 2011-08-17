class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :name
      t.references :page
    end
    add_index :features, :page_id
  end
end
