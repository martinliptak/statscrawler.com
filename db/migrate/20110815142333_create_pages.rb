class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :url
      t.string :server
      t.string :engine
      t.string :doctype
      t.string :framework
    end
  end
end
