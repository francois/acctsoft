class RenumberTxnAccountPositions < ActiveRecord::Migration
  class Txn < ActiveRecord::Base
    has_many :lines,  :class_name => 'RenumberTxnAccountPositions::TxnAccount',
                      :order => 'position', :dependent => :delete_all
  end

  class TxnAccount < ActiveRecord::Base; end

  def self.up
    Txn.find(:all).each do |txn|
      txn.lines.each_with_index do |line, index|
        line.update_attribute(:position, 1 + index)
      end
    end
  end

  def self.down
  end
end
