# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20110816165437) do

  create_table "domains", :force => true do |t|
    t.string   "name"
    t.string   "tld"
    t.integer  "page_id"
    t.integer  "location_id"
    t.boolean  "ipv6"
    t.datetime "analyzed_at"
  end

  add_index "domains", ["location_id"], :name => "index_domains_on_location_id"
  add_index "domains", ["name"], :name => "index_domains_on_name", :unique => true
  add_index "domains", ["page_id"], :name => "index_domains_on_page_id"

  create_table "features", :force => true do |t|
    t.string  "name"
    t.integer "page_id"
  end

  add_index "features", ["page_id", "name"], :name => "index_features_on_page_id_and_name"

  create_table "locations", :force => true do |t|
    t.string "ip"
    t.string "country"
    t.string "city"
    t.float  "longitude"
    t.float  "latitude"
  end

  add_index "locations", ["city", "id"], :name => "index_locations_on_city_and_id"
  add_index "locations", ["country", "id"], :name => "index_locations_on_country_and_id"
  add_index "locations", ["ip"], :name => "index_locations_on_ip", :unique => true
  add_index "locations", ["longitude", "latitude", "city", "id"], :name => "index_locations_on_longitude_and_latitude_and_city_and_id"

  create_table "pages", :force => true do |t|
    t.string "url"
    t.string "description", :limit => 1024
    t.string "keywords",    :limit => 512
    t.string "server"
    t.string "engine"
    t.string "doctype"
    t.string "framework"
  end

  add_index "pages", ["doctype", "id"], :name => "index_pages_on_doctype_and_id"
  add_index "pages", ["engine", "id"], :name => "index_pages_on_engine_and_id"
  add_index "pages", ["framework", "id"], :name => "index_pages_on_framework_and_id"
  add_index "pages", ["server", "id"], :name => "index_pages_on_server_and_id"
  add_index "pages", ["url"], :name => "index_pages_on_url", :unique => true

  create_table "sources", :force => true do |t|
    t.integer "page_id"
    t.text    "headers"
    t.text    "body"
  end

  add_index "sources", ["page_id"], :name => "index_sources_on_page_id"

end
