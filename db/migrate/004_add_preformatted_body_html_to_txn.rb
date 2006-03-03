class AddPreformattedBodyHtmlToTxn < ActiveRecord::Migration
  def self.up
    add_column :txns, :description_html, :text
    Txn.find(:all).each do |txn|
      txn.save!
    end
  end

  def self.down
    remove_column :txns, :description_html
  end
end
