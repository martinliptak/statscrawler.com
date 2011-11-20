class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.references :page
      t.text :headers
      t.text :body
    end
    add_index :sources, :page_id
  end
end
