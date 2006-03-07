class Item < ActiveRecord::Base
  validates_presence_of :no, :charge_account_no, :description
  validates_numericality_of :no

  def charge_account
    Account.find_by_no(self.charge_account_no)
  end
end
