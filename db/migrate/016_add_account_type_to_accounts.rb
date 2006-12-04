class AddAccountTypeToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :account_type, :string, :limit => 30, :null => false
  end

  def self.down
    remove_column :accounts, :account_type
  end
end
