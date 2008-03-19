# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 18) do

  create_table "account_configurations", :force => true do |t|
    t.string  "name",       :default => "", :null => false
    t.integer "account_no", :default => 0,  :null => false
  end

  create_table "account_types", :force => true do |t|
    t.integer "position"
    t.string  "name"
    t.string  "designation"
  end

  create_table "accounts", :force => true do |t|
    t.integer "no"
    t.string  "name"
    t.string  "description"
    t.string  "account_type", :limit => 30, :default => "", :null => false
  end

  create_table "check_distributions", :force => true do |t|
    t.integer "check_id",                        :default => 0, :null => false
    t.integer "position",                        :default => 0, :null => false
    t.integer "account_id",                      :default => 0, :null => false
    t.integer "amount_dt_cents"
    t.string  "amount_dt_currency", :limit => 6
    t.integer "amount_ct_cents"
    t.string  "amount_ct_currency", :limit => 6
  end

  create_table "checks", :force => true do |t|
    t.string  "no",              :limit => 12
    t.date    "written_on"
    t.string  "beneficiary"
    t.integer "amount_cents"
    t.string  "amount_currency", :limit => 8
    t.text    "reason"
    t.integer "txn_id"
    t.integer "bank_account_id"
  end

  create_table "companies", :force => true do |t|
    t.string  "name"
    t.integer "year"
  end

  create_table "customers", :force => true do |t|
    t.string   "name",                               :default => "", :null => false
    t.string   "abbreviation",          :limit => 8, :default => "", :null => false
    t.string   "phone"
    t.string   "address_line1"
    t.string   "address_line2"
    t.string   "address_line3"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_zip"
    t.string   "address_country"
    t.boolean  "charge_federal_tax"
    t.boolean  "charge_provincial_tax"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_items", :force => true do |t|
    t.integer  "invoice_id",       :default => 0, :null => false
    t.integer  "position",         :default => 0, :null => false
    t.integer  "item_id",          :default => 0, :null => false
    t.string   "description"
    t.integer  "quantity",         :default => 0, :null => false
    t.integer  "unit_price_cents", :default => 0, :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "invoice_payments", :force => true do |t|
    t.integer  "payment_id",   :default => 0, :null => false
    t.integer  "invoice_id",   :default => 0, :null => false
    t.integer  "amount_cents", :default => 0, :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "invoices", :force => true do |t|
    t.integer  "no",          :default => 0, :null => false
    t.integer  "customer_id", :default => 0, :null => false
    t.date     "invoiced_on",                :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "txn_id"
    t.datetime "posted_at"
  end

  create_table "items", :force => true do |t|
    t.integer  "no",                :default => 0,  :null => false
    t.string   "description",       :default => "", :null => false
    t.integer  "charge_account_no", :default => 0,  :null => false
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "payments", :force => true do |t|
    t.integer  "customer_id",  :default => 0,  :null => false
    t.date     "paid_on"
    t.date     "received_on",                  :null => false
    t.string   "reference",    :default => "", :null => false
    t.integer  "amount_cents", :default => 0,  :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "txn_id"
    t.datetime "posted_at"
  end

  create_table "reconciliations", :force => true do |t|
    t.string   "description"
    t.integer  "account_id",    :default => 0, :null => false
    t.date     "statement_on",                 :null => false
    t.datetime "reconciled_at",                :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "txn_accounts", :force => true do |t|
    t.integer "position"
    t.integer "txn_id"
    t.integer "account_id"
    t.integer "amount_dt_cents"
    t.string  "amount_dt_currency", :limit => 6
    t.integer "amount_ct_cents"
    t.string  "amount_ct_currency", :limit => 6
    t.integer "reconciliation_id"
  end

  add_index "txn_accounts", ["txn_id", "position"], :name => "by_txn_position", :unique => true

  create_table "txns", :force => true do |t|
    t.date     "posted_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.text     "description_html"
  end

  add_index "txns", ["posted_on", "id"], :name => "by_posted_date"

end
