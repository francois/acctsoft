class AddPostedAtToPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :txn_id, :integer
    add_column :payments, :posted_at, :datetime
  end

  def self.down
    remove_column :payments, :posted_at
    remove_column :payments, :txn_id
  end
end
