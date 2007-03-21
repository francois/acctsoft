class AddAccountConfigurations < ActiveRecord::Migration
  class AccountConfiguration < ActiveRecord::Base; end

  def self.up
    create_table :account_configurations do |t|
      t.column :name, :string, :null => false
      t.column :account_no, :integer, :null => false
    end

    AccountConfiguration.create!(:name => 'Comptes Clients', :account_no => 1100)
    AccountConfiguration.create!(:name => 'Encaisse', :account_no => 1000)
    AccountConfiguration.create!(:name => 'TPS à payer', :account_no => 2110)
    AccountConfiguration.create!(:name => 'TVQ à payer', :account_no => 2120)
    AccountConfiguration.create!(:name => 'TPS à recevoir', :account_no => 1510)
    AccountConfiguration.create!(:name => 'TVQ à recevoir', :account_no => 1520)
  end

  def self.down
    drop_table :account_configurations
  end

  class AccountConfiguration < ActiveRecord::Base; end
end
