class PopulateDefaultData < ActiveRecord::Migration
  def self.up
    AccountType.create!(:name => 'Actif', :designation => 'actif')
    AccountType.create!(:name => 'Passif', :designation => 'passif')
    AccountType.create!(:name => 'Avoir', :designation => 'avoir')
    AccountType.create!(:name => 'Produit', :designation => 'produit')
    AccountType.create!(:name => 'Charge', :designation => 'charge')
  end

  def self.down
    AccountType.delete_all
  end

  class AccountType < ActiveRecord::Base; end
end
