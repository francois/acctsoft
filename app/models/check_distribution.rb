class CheckDistribution < ActiveRecord::Base
  acts_as_list
  belongs_to :account
  belongs_to :check

  acts_as_money :amount_dt, :amount_ct, :allow_nil => false

  validates_presence_of :check_id, :account_id
  validates_uniqueness_of :account_id, :scope => :check_id
  before_validation DebitCreditNormalizer.new

  def no
    self.account.no
  end

  def no=(account_no)
    self.account = Account.find_by_no(account_no)
  end

  def name
    self.account.name
  end
end
