class RemoveUniqueOnTxnAccountsPositionIndex < ActiveRecord::Migration
  def self.up
    remove_index :txn_accounts, :name => :by_txn_position
    add_index :txn_accounts, %w(txn_id position), :name => :by_txn_position
  end

  def self.down
    remove_index :txn_accounts, :name => :by_txn_position
    add_index :txn_accounts, %w(txn_id position), :unique => true, :name => :by_txn_position
  end
end
