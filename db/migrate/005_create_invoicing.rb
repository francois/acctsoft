class CreateInvoicing < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.column :name, :string, :null => false
      t.column :abbreviation, :string, :limit => 8, :null => false
      t.column :phone, :string
      t.column :address_line1, :string
      t.column :address_line2, :string
      t.column :address_line3, :string
      t.column :address_city, :string
      t.column :address_state, :string
      t.column :address_zip, :string
      t.column :address_country, :string
      t.column :charge_federal_tax, :boolean
      t.column :charge_provincial_tax, :boolean
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    create_table :payments do |t|
      t.column :customer_id, :integer, :null => false
      t.column :paid_on, :date, :null => false
      t.column :received_on, :date, :null => false
      t.column :reference, :string, :null => false
      t.column :amount_cents, :integer, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end

    create_table :invoice_payments do |t|
      t.column :payment_id, :integer, :null => false
      t.column :invoice_id, :integer, :null => false
      t.column :amount_cents, :integer, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end

    create_table :invoices do |t|
      t.column :no, :integer, :null => false
      t.column :customer_id, :integer, :null => false
      t.column :invoiced_on, :date, :null => false
      t.column :posted_on, :date, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end

    create_table :invoice_items do |t|
      t.column :invoice_id, :integer, :null => false
      t.column :position, :integer, :null => false
      t.column :item_id, :integer, :null => false
      t.column :description, :string
      t.column :quantity, :integer, :null => false
      t.column :unit_price_cents, :integer, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end

    create_table :items do |t|
      t.column :no, :integer, :null => false
      t.column :description, :string, :null => false
      t.column :charge_account_no, :integer, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :items
    drop_table :invoice_items
    drop_table :invoices
    drop_table :invoice_payments
    drop_table :payments
    drop_table :customers
  end
end
