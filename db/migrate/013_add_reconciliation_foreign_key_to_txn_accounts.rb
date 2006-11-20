class AddReconciliationForeignKeyToTxnAccounts < ActiveRecord::Migration
  def self.up
    add_column :txn_accounts, :reconciliation_id, :integer
  end

  def self.down
    remove_column :txn_accounts, :reconciliation_id
  end
end
