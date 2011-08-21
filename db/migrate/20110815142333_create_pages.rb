class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :url
      t.string :server
      t.string :engine
      t.string :doctype
      t.string :framework
    end

    add_index :pages, :url, :unique => true
  end
end
