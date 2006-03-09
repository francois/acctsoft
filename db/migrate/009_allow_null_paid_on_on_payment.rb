class AllowNullPaidOnOnPayment < ActiveRecord::Migration
  def self.up
    change_column :payments, :paid_on, :date, :null => true
  end

  def self.down
    change_column :payments, :paid_on, :date, :null => false
  end
end
