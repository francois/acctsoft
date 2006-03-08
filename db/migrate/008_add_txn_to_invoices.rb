class AddTxnToInvoices < ActiveRecord::Migration
  def self.up
    add_column :invoices, :txn_id, :integer
    say_with_time('Renaming posted_on to posted_at') do
      add_column :invoices, :posted_at, :datetime
      Invoice.update_all('posted_at = posted_on')
      remove_column :invoices, :posted_on
    end
  end

  def self.down
    say_with_time('Renaming posted_at to posted_on') do
      add_column :invoices, :posted_on, :datetime
      Invoice.update_all('posted_on = posted_at')
      remove_column :invoices, :posted_at
    end
    remove_column :invoices, :txn_id
  end
end
