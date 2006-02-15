class AddTxnIndexes < ActiveRecord::Migration
  def self.up
    add_index :txns, [:posted_on, :id], :name => 'by_posted_date'
    add_index :txn_accounts, [:txn_id, :position], :name => 'by_txn_position', :unique => true
  end

  def self.down
    remove_index :txns, :name => 'by_posted_date'
    remove_index :txn_accounts, :name => 'by_txn_position'
  end
end
