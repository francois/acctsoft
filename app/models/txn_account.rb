class TxnAccount < ActiveRecord::Base
  acts_as_list :scope => 'txn_id'

  belongs_to :txn
  belongs_to :account

  composed_of :amount_dt, :class_name => 'Money',
      :mapping => [%w(amount_dt_cents cents), %w(amount_dt_currency currency)]
  composed_of :amount_ct, :class_name => 'Money',
      :mapping => [%w(amount_ct_cents cents), %w(amount_ct_currency currency)]

  before_validation :normalize_amounts

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

  protected
  def normalize_amounts
    return if self.amount_dt.zero? or self.amount_ct.zero?
    if self.amount_dt > self.amount_ct then
      self.amount_dt -= self.amount_ct
      self.amount_ct = Money.empty
    else
      self.amount_ct -= self.amount_dt
      self.amount_dt = Money.empty
    end
  end
end
