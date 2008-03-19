class QuickTxn
  attr_accessor :posted_on, :description, :debit_account, :credit_account, :amount

  def initialize(hash={})
    hash.each_pair do |attr, value|
      self.send(attr.to_s + "=", value)
    end
  end

  def save
    Txn.transaction do
      txn = Txn.new(:posted_on => self.posted_on, :description => self.description)
      txn.lines.build(:name => self.debit_account, :amount_dt => self.amount)
      txn.lines.build(:name => self.credit_account, :amount_ct => self.amount)

      txn.save
    end
  end
end
