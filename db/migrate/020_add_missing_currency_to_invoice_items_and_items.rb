class AddMissingCurrencyToInvoiceItemsAndItems < ActiveRecord::Migration
  def self.up
    add_column :invoice_items, :unit_price_currency, :string, :limit => 4, :default => "CAD"
  end

  def self.down
    remove_column :invoice_items, :unit_price_currency
  end
end
