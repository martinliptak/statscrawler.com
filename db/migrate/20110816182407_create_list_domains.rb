class CreateListDomains < ActiveRecord::Migration
  def change
    create_table :list_domains do |t|
      t.string :list
      t.references :domain
    end
    add_index :list_domains, :domain_id
  end
end
