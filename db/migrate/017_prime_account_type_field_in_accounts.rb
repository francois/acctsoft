class PrimeAccountTypeFieldInAccounts < ActiveRecord::Migration
  def self.up
    Account.find(:all).each do |account|
      type = AccountType.find(account.type_id)
      case type.designation
      when 'actif'
        account.account_type = 'asset'
      when 'passif'
        account.account_type = 'liability'
      when 'produit'
        account.account_type = 'income'
      when 'charge'
        account.account_type = 'expense'
      when 'avoir'
        account.account_type = 'equity'
      else
        raise ArgumentError, "Unknown designation: #{type.designation.inspect}"
      end

      account.save!
    end
  end

  def self.down
  end

  class Account < ActiveRecord::Base; end
  class AccountType < ActiveRecord::Base; end
end
