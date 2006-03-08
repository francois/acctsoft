class AccountConfiguration < ActiveRecord::Base
  validates_presence_of :name, :account_no
  validates_length_of :name, :minimum => 1
  validates_numericality_of :account_no

  attr_accessible :account_no

  def account
    account = Account.find_by_no(self.account_no)
    raise ActiveRecord::RecordNotFound, "Could not find account #{self.account_no} (#{self.name})" \
        unless account
    account
  end

  def self.get(name)
    ac = self.find_by_name(name)
    raise ActiveRecord::RecordNotFound, "Could not find account named #{name.inspect}" unless ac
    raise ActiveRecord::RecordInvalid, "Account #{name.inspect} is not configuration" unless ac.account
    ac.account
  end
end
