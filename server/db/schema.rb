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

ActiveRecord::Schema.define(:version => 20120112122200) do

  create_table "concretes", :force => true do |t|
    t.integer  "parkingplane_id"
    t.string   "category"
    t.integer  "x"
    t.integer  "y"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "concretes", ["parkingplane_id", "x", "y"], :name => "index_concretes_on_parkingplane_id_and_x_and_y", :unique => true

  create_table "operators", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "failed_attempts",                       :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "operators", ["authentication_token"], :name => "index_operators_on_authentication_token", :unique => true
  add_index "operators", ["confirmation_token"], :name => "index_operators_on_confirmation_token", :unique => true
  add_index "operators", ["email"], :name => "index_operators_on_email", :unique => true
  add_index "operators", ["reset_password_token"], :name => "index_operators_on_reset_password_token", :unique => true
  add_index "operators", ["unlock_token"], :name => "index_operators_on_unlock_token", :unique => true

  create_table "parkinglots", :force => true do |t|
    t.integer  "parkingplane_id"
    t.string   "category"
    t.boolean  "taken"
    t.integer  "x"
    t.integer  "y"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "parkinglots", ["parkingplane_id", "x", "y"], :name => "index_parkinglots_on_parkingplane_id_and_x_and_y", :unique => true

  create_table "parkingplanes", :force => true do |t|
    t.string   "name"
    t.integer  "parkingramp_id"
    t.integer  "sorting"
    t.integer  "lots_total"
    t.integer  "lots_taken"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parkingramps", :force => true do |t|
    t.string   "name"
    t.integer  "operator_id"
    t.string   "category"
    t.string   "info_status"
    t.text     "info_pricing"
    t.text     "info_openinghours"
    t.text     "info_address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lots_taken",        :default => 0
    t.integer  "lots_total",        :default => 0
  end

  create_table "stats", :force => true do |t|
    t.integer  "parkingplane_id"
    t.integer  "lots_total"
    t.integer  "lots_taken"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_at_year"
    t.integer  "created_at_month"
    t.integer  "created_at_day"
    t.integer  "created_at_hour"
  end

end
