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
    add_index :pages, [:engine, :id]
    add_index :pages, [:server, :id]
    add_index :pages, [:doctype, :id]
    add_index :pages, [:framework, :id]
  end
end
