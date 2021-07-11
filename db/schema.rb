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

ActiveRecord::Schema.define(:version => 36) do

  create_table "agents", :force => true do |t|
    t.string   "name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "contacts", :force => true do |t|
    t.string   "name"
    t.string   "tel"
    t.text     "address"
    t.integer  "hotel_src_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "cid"
  end

  create_table "expenses", :force => true do |t|
    t.integer  "room_list_id"
    t.integer  "product_id"
    t.decimal  "price"
    t.decimal  "per_unit"
    t.integer  "user_id"
    t.integer  "vol"
    t.integer  "hotel_src_id"
    t.integer  "input_type_id"
    t.integer  "folio_id"
    t.date     "at_date"
    t.string   "ref"
    t.integer  "shift_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "floors", :force => true do |t|
    t.string   "name"
    t.integer  "seq"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "folio_tmps", :force => true do |t|
    t.integer  "folio_id"
    t.string   "folio_no"
    t.string   "contact_name"
    t.text     "contact_address"
    t.datetime "arvl_at"
    t.datetime "dpt_at"
    t.date     "at_date"
    t.string   "room_no"
    t.string   "des"
    t.decimal  "debit"
    t.decimal  "credit"
    t.string   "ref"
    t.string   "username"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "folios", :force => true do |t|
    t.integer  "input_type_id"
    t.string   "folio_no"
    t.string   "remark"
    t.integer  "hotel_src_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "shift_id"
    t.date     "at_date"
  end

  create_table "gst_levels", :force => true do |t|
    t.string   "name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "gst_types", :force => true do |t|
    t.string   "name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "history_shifts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "shift_id"
    t.datetime "login_at"
    t.datetime "logout_at"
    t.integer  "hotel_src_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "hotel_srcs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "input_types", :force => true do |t|
    t.string   "tel"
    t.integer  "nation_id"
    t.integer  "agent_id"
    t.integer  "gst_type_id"
    t.integer  "gst_level_id"
    t.integer  "src_gst_id"
    t.integer  "prpt_grp_id"
    t.integer  "rsvt_type_id"
    t.integer  "rsvt_status_id"
    t.integer  "adult"
    t.integer  "child"
    t.integer  "night"
    t.datetime "arvl_at"
    t.datetime "dpt_at"
    t.integer  "input_by"
    t.string   "location"
    t.integer  "rate_code_id"
    t.string   "ref"
    t.text     "remark"
    t.integer  "hotel_src_id"
    t.integer  "contact_id"
    t.string   "type"
    t.string   "stay_status",    :limit => 1
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "log_expenses", :force => true do |t|
    t.integer  "room_list_id"
    t.integer  "product_id"
    t.decimal  "price"
    t.decimal  "per_unit"
    t.integer  "user_id"
    t.integer  "vol"
    t.integer  "hotel_src_id"
    t.integer  "input_type_id"
    t.integer  "folio_id"
    t.date     "at_date"
    t.string   "ref"
    t.integer  "shift_id"
    t.integer  "expense_id"
    t.string   "act"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "log_move_rooms", :force => true do |t|
    t.integer  "input_type_id"
    t.integer  "room_list_id"
    t.integer  "room_old_id"
    t.integer  "room_new_id"
    t.integer  "user_id"
    t.string   "remark"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "nations", :force => true do |t|
    t.string   "name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "out_standings", :force => true do |t|
    t.string   "report"
    t.string   "room"
    t.string   "room_type"
    t.string   "gst_type"
    t.string   "gst_name"
    t.date     "arvl_at"
    t.date     "dpt_at"
    t.decimal  "room_rate"
    t.decimal  "ext_bed_rate"
    t.decimal  "folio"
    t.decimal  "credit"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "product_places", :force => true do |t|
    t.string   "name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.integer  "hotel_src_id"
    t.decimal  "price"
    t.string   "category",         :limit => 1
    t.string   "config",           :limit => 1
    t.string   "used",             :limit => 1, :default => "1"
    t.integer  "product_place_id"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "prpt_grps", :force => true do |t|
    t.string   "name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "rate_code_details", :force => true do |t|
    t.integer  "rate_code_id"
    t.integer  "room_type_id"
    t.decimal  "room_rate",    :default => 0.0
    t.decimal  "abf_rate",     :default => 0.0
    t.decimal  "ext_bed_rate", :default => 0.0
    t.integer  "hotel_src_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "rate_codes", :force => true do |t|
    t.string   "name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "room_lists", :force => true do |t|
    t.integer  "room_type_id"
    t.integer  "room_id"
    t.decimal  "room_rate"
    t.datetime "arvl_at"
    t.datetime "dpt_at"
    t.integer  "input_type_id"
    t.string   "status"
    t.integer  "arvl_by"
    t.integer  "dpt_by"
    t.integer  "hotel_src_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "room_types", :force => true do |t|
    t.string   "name"
    t.string   "short_name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "rooms", :force => true do |t|
    t.integer  "floor_id"
    t.string   "room_no"
    t.string   "used",         :limit => 1, :default => "1"
    t.string   "status",       :limit => 1
    t.integer  "seq"
    t.integer  "hotel_src_id"
    t.integer  "room_type_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "rsvt_statuses", :force => true do |t|
    t.string   "name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.string   "status",       :limit => 1
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "rsvt_types", :force => true do |t|
    t.string   "name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "shifts", :force => true do |t|
    t.string   "name"
    t.time     "start_at"
    t.time     "end_at"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "src_gsts", :force => true do |t|
    t.string   "name"
    t.string   "used",         :limit => 1, :default => "1"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "stay_lists", :force => true do |t|
    t.integer  "room_list_id"
    t.string   "fname"
    t.string   "lname"
    t.decimal  "abf_rate"
    t.decimal  "ext_bed_rate"
    t.string   "status",       :limit => 1
    t.integer  "hotel_src_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "fname"
    t.string   "lname"
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "lang",          :default => "en"
    t.string   "role",          :default => "user"
    t.integer  "hotel_src_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

end
