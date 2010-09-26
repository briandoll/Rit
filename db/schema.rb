# This file is auto-generated from the current state of the database. Instead of editing this file,
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091204020821) do

  create_table "events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "publish"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plate_editions", :force => true do |t|
    t.integer  "plate_id"
    t.integer  "event_id"
    t.string   "name"
    t.text     "content"
    t.text     "description"
    t.boolean  "publish",         :default => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean  "default_edition", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plate_editions", ["plate_id", "event_id"], :name => "index_plate_editions_on_plate_id_and_event_id", :unique => true

  create_table "plate_set_plates", :force => true do |t|
    t.integer  "plate_set_id"
    t.string   "plate_name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plate_sets", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "layout_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plates", :force => true do |t|
    t.string   "layout_name"
    t.string   "instance_name"
    t.string   "plate_name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plates", ["layout_name", "instance_name", "plate_name"], :name => "index_plates_on_layout_name_and_instance_name_and_plate_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "confirmation_token", :limit => 128
    t.string   "remember_token",     :limit => 128
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                             :default => false
    t.boolean  "active",                            :default => true,  :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id", "confirmation_token"], :name => "index_users_on_id_and_confirmation_token"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
