class AddCurrencyToPaymentsAndInvoicePayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :amount_currency, :string, :limit => 4, :default => "CAD"
    add_column :invoice_payments, :amount_currency, :string, :limit => 4, :default => "CAD"
  end

  def self.down
    remove_column :invoice_payments, :amount_currency
    remove_column :payments, :amount_currency
  end
end
