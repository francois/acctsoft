class RemoveTypeIdFromAccounts < ActiveRecord::Migration
  def self.up
    remove_column :accounts, :type_id
  end

  def self.down
    add_column :accounts, :type_id, :integer
  end
end
