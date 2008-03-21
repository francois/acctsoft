class QuickTxn
  attr_accessor :posted_on, :description, :debit_account, :credit_account, :amount

  def initialize(hash={})
    hash.each_pair do |attr, value|
      self.send(attr.to_s + "=", value)
    end
  end

  def debit_account=(value)
    @debit_account = value.kind_of?(Account) ? value : Account.find_by_no_or_name(value)
  end

  def credit_account=(value)
    @credit_account = value.kind_of?(Account) ? value : Account.find_by_no_or_name(value)
  end

  def to_txn
    txn = Txn.new(:posted_on => self.posted_on, :description => self.description)
    txn.lines.build(:account => self.debit_account, :amount_dt => self.amount)
    txn.lines.build(:account => self.credit_account, :amount_ct => self.amount)
    txn
  end

  def save
    Txn.transaction do
      self.to_txn.save
    end
  end

  def logger
    ActiveRecord::Base.logger
  end
end
