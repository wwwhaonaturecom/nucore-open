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

ActiveRecord::Schema.define(:version => 20120502223446) do

  create_table "account_users", :force => true do |t|
    t.integer  "account_id",               :precision => 38, :scale => 0, :null => false
    t.integer  "user_id",                  :precision => 38, :scale => 0, :null => false
    t.string   "user_role",  :limit => 50,                                :null => false
    t.datetime "created_at",                                              :null => false
    t.integer  "created_by",               :precision => 38, :scale => 0, :null => false
    t.datetime "deleted_at"
    t.integer  "deleted_by",               :precision => 38, :scale => 0
  end

  add_foreign_key "account_users", "accounts", :name => "fk_accounts"

  create_table "accounts", :force => true do |t|
    t.string   "type",                   :limit => 50,                                 :null => false
    t.string   "account_number",         :limit => 50,                                 :null => false
    t.string   "description",            :limit => 50,                                 :null => false
    t.datetime "expires_at",                                                           :null => false
    t.string   "name_on_card",           :limit => 200
    t.integer  "expiration_month",                      :precision => 38, :scale => 0
    t.integer  "expiration_year",                       :precision => 38, :scale => 0
    t.datetime "created_at",                                                           :null => false
    t.integer  "created_by",                            :precision => 38, :scale => 0, :null => false
    t.datetime "updated_at"
    t.integer  "updated_by",                            :precision => 38, :scale => 0
    t.datetime "suspended_at"
    t.text     "remittance_information"
    t.integer  "facility_id",                           :precision => 38, :scale => 0
    t.integer  "affiliate_id",                          :precision => 38, :scale => 0
    t.string   "affiliate_other"
  end

  add_index "accounts", ["affiliate_id"], :name => "index_accounts_on_affiliate_id", :tablespace => "bc_nucore"

  add_foreign_key "accounts", "facilities", :name => "fk_account_facility_id"

  create_table "affiliates", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "budgeted_chart_strings", :force => true do |t|
    t.string   "fund",       :limit => 20, :null => false
    t.string   "dept",       :limit => 20, :null => false
    t.string   "project",    :limit => 20
    t.string   "activity",   :limit => 20
    t.string   "account",    :limit => 20
    t.datetime "starts_at",                :null => false
    t.datetime "expires_at",               :null => false
  end

  create_table "bundle_products", :force => true do |t|
    t.integer "bundle_product_id", :precision => 38, :scale => 0, :null => false
    t.integer "product_id",        :precision => 38, :scale => 0, :null => false
    t.integer "quantity",          :precision => 38, :scale => 0, :null => false
  end

  add_foreign_key "bundle_products", "products", :name => "fk_bundle_prod_bundle"
  add_foreign_key "bundle_products", "products", :name => "fk_bundle_prod_prod", :column => "bundle_product_id"

  create_table "external_service_passers", :force => true do |t|
    t.integer  "external_service_id