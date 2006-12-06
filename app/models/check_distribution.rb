class CheckDistribution < ActiveRecord::Base
  acts_as_list
  belongs_to :account
  belongs_to :check
  composed_of :amount_dt, :class_name => 'Money',
      :mapping => [%w(amount_dt_cents cents), %w(amount_dt_currency currency)]
  composed_of :amount_ct, :class_name => 'Money',
      :mapping => [%w(amount_ct_cents cents), %w(amount_ct_currency currency)]

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

  def debit=(amount)
    self.amount_dt = amount.to_money
  end

  def debit
    self.amount_dt
  end

  def credit=(amount)
    self.amount_ct = amount.to_money
  end

  def credit
    self.amount_ct
  end
end
