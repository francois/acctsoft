class TxnAccount < ActiveRecord::Base
  acts_as_list

  belongs_to :txn
  belongs_to :account

  composed_of :amount_dt, :class_name => 'Money',
      :mapping => [%w(amount_dt_cents cents), %w(amount_dt_currency currency)]
  composed_of :amount_ct, :class_name => 'Money',
      :mapping => [%w(amount_ct_cents cents), %w(amount_ct_currency currency)]

  before_validation :normalize_amounts

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
