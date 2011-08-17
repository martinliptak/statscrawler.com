# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110816182407) do

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.integer  "page_id"
    t.integer  "location_id"
    t.datetime "analyzed_at"
  end

  add_index "domains", ["location_id"], :name => "index_domains_on_domain_id"
  add_index "domains", ["page_id"], :name => "index_domains_on_page_id"

  create_table "features", :force => true do |t|
    t.string  "name"
    t.integer "page_id"
  end

  add_index "features", ["page_id"], :name => "index_features_on_page_id"

  create_table "list_domains", :force => true do |t|
    t.string  "list"
    t.integer "domain_id"
  end

  add_index "list_domains", ["domain_id"], :name => "index_list_domains_on_domain_id"

  create_table "locations", :force => true do |t|
    t.string "ip"
    t.string "country"
    t.string "city"
    t.float  "longitude"
    t.float  "latitude"
  end

  create_table "pages", :force => true do |t|
    t.string "url"
    t.string "server"
    t.string "engine"
    t.string "doctype"
    t.string "framework"
  end

  create_table "sources", :force => true do |t|
    t.integer  "page_id"
    t.text     "headers"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sources", ["page_id"], :name => "index_sources_on_page_id"

end
