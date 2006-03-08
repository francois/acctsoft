class AddAccountConfigurations < ActiveRecord::Migration
  class AccountConfiguration < ActiveRecord::Base; end

  def self.up
    create_table :account_configurations do |t|
      t.column :name, :string, :null => false
      t.column :account_no, :integer, :null => false
    end

    AccountConfiguration.create!(:name => 'Comptes Clients')
    AccountConfiguration.create!(:name => 'Encaisse')
    AccountConfiguration.create!(:name => 'TPS à payer')
    AccountConfiguration.create!(:name => 'TVQ à payer')
    AccountConfiguration.create!(:name => 'TPS à recevoir')
    AccountConfiguration.create!(:name => 'TVQ à recevoir')
  end

  def self.down
    drop_table :account_configurations
  end
end
