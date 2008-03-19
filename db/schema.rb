# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 20) do

  create_table "account_configurations", :force => true do |t|
    t.column "name",       :string,  :default => "", :null => false
    t.column "account_no", :integer, :default => 0,  :null => false
  end

  create_table "account_types", :force => true do |t|
    t.column "position",    :integer
    t.column "name",        :string
    t.column "designation", :string
  end

  create_table "accounts", :force => true do |t|
    t.column "no",           :integer
    t.column "name",         :string
    t.column "description",  :string
    t.column "account_type", :string,  :limit => 30, :default => "", :null => false
  end

  create_table "check_distributions", :force => true do |t|
    t.column "check_id",           :integer,              :default => 0, :null => false
    t.column "position",           :integer,              :default => 0, :null => false
    t.column "account_id",         :integer,              :default => 0, :null => false
    t.column "amount_dt_cents",    :integer
    t.column "amount_dt_currency", :string,  :limit => 6
    t.column "amount_ct_cents",    :integer
    t.column "amount_ct_currency", :string,  :limit => 6
  end

  create_table "checks", :force => true do |t|
    t.column "no",              :string,  :limit => 12
    t.column "written_on",      :date
    t.column "beneficiary",     :string
    t.column "amount_cents",    :integer
    t.column "amount_currency", :string,  :limit => 8
    t.column "reason",          :text
    t.column "txn_id",          :integer
    t.column "bank_account_id", :integer
  end

  create_table "companies", :force => true do |t|
    t.column "name", :string
    t.column "year", :integer
  end

  create_table "customers", :force => true do |t|
    t.column "name",                  :string,                :default => "", :null => false
    t.column "abbreviation",          :string,   :limit => 8, :default => "", :null => false
    t.column "phone",                 :string
    t.column "address_line1",         :string
    t.column "address_line2",         :string
    t.column "address_line3",         :string
    t.column "address_city",          :string
    t.column "address_state",         :string
    t.column "address_zip",           :string
    t.column "address_country",       :string
    t.column "charge_federal_tax",    :boolean
    t.column "charge_provincial_tax", :boolean
    t.column "created_at",            :datetime
    t.column "updated_at",            :datetime
  end

  create_table "invoice_items", :force => true do |t|
    t.column "invoice_id",          :integer,               :default => 0,     :null => false
    t.column "position",            :integer,               :default => 0,     :null => false
    t.column "item_id",             :integer,               :default => 0,     :null => false
    t.column "description",         :string
    t.column "quantity",            :integer,               :default => 0,     :null => false
    t.column "unit_price_cents",    :integer,               :default => 0,     :null => false
    t.column "created_at",          :datetime,                                 :null => false
    t.column "updated_at",          :datetime,                                 :null => false
    t.column "unit_price_currency", :string,   :limit => 4, :default => "CAD"
  end

  create_table "invoice_payments", :force => true do |t|
    t.column "payment_id",      :integer,               :default => 0,     :null => false
    t.column "invoice_id",      :integer,               :default => 0,     :null => false
    t.column "amount_cents",    :integer,               :default => 0,     :null => false
    t.column "created_at",      :datetime,                                 :null => false
    t.column "updated_at",      :datetime,                                 :null => false
    t.column "amount_currency", :string,   :limit => 4, :default => "CAD"
  end

  create_table "invoices", :force => true do |t|
    t.column "no",          :integer,  :default => 0, :null => false
    t.column "customer_id", :integer,  :default => 0, :null => false
    t.column "invoiced_on", :date,                    :null => false
    t.column "created_at",  :datetime,                :null => false
    t.column "updated_at",  :datetime,                :null => false
    t.column "txn_id",      :integer
    t.column "posted_at",   :datetime
  end

  create_table "items", :force => true do |t|
    t.column "no",                :integer,  :default => 0,  :null => false
    t.column "description",       :string,   :default => "", :null => false
    t.column "charge_account_no", :integer,  :default => 0,  :null => false
    t.column "created_at",        :datetime,                 :null => false
    t.column "updated_at",        :datetime,                 :null => false
  end

  create_table "payments", :force => true do |t|
    t.column "customer_id",     :integer,               :default => 0,     :null => false
    t.column "paid_on",         :date
    t.column "received_on",     :date,                                     :null => false
    t.column "reference",       :string,                :default => "",    :null => false
    t.column "amount_cents",    :integer,               :default => 0,     :null => false
    t.column "created_at",      :datetime,                                 :null => false
    t.column "updated_at",      :datetime,                                 :null => false
    t.column "txn_id",          :integer
    t.column "posted_at",       :datetime
    t.column "amount_currency", :string,   :limit => 4, :default => "CAD"
  end

  create_table "reconciliations", :force => true do |t|
    t.column "description",   :string
    t.column "account_id",    :integer,  :default => 0, :null => false
    t.column "statement_on",  :date,                    :null => false
    t.column "reconciled_at", :datetime,                :null => false
    t.column "created_at",    :datetime,                :null => false
    t.column "updated_at",    :datetime,                :null => false
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data",       :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "txn_accounts", :force => true do |t|
    t.column "position",           :integer
    t.column "txn_id",             :integer
    t.column "account_id",         :integer
    t.column "amount_dt_cents",    :integer
    t.column "amount_dt_currency", :string,  :limit => 6
    t.column "amount_ct_cents",    :integer
    t.column "amount_ct_currency", :string,  :limit => 6
    t.column "reconciliation_id",  :integer
  end

  add_index "txn_accounts", ["txn_id", "position"], :name => "by_txn_position", :unique => true

  create_table "txns", :force => true do |t|
    t.column "posted_on",        :date
    t.column "created_at",       :datetime
    t.column "updated_at",       :datetime
    t.column "description",      :text
    t.column "description_html", :text
  end

  add_index "txns", ["posted_on", "id"], :name => "by_posted_date"

end
