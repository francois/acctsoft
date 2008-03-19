class TxnAccount < ActiveRecord::Base
  acts_as_list :scope => :txn_id

  belongs_to :txn
  belongs_to :account
  belongs_to :reconciliation
  validates_presence_of :account_id

  acts_as_money :amount_dt, :amount_ct, :allow_nil => false

  before_validation DebitCreditNormalizer.new
  validate :non_nil_volume

  def no
    self.account.no
  end

  def no=(account_no)
    self.account = Account.find_by_no(account_no)
  end

  def name
    self.account.name
  end

  def name=(name)
    self.account = Account.find_by_name(name)
  end

  def reconcile!(reconciliation)
    self.reconciliation = reconciliation
    self.save!
  end

  def unconcile!
    self.reconciliation = nil
    self.save!
  end

  protected
  def non_nil_volume
    return unless (self.amount_dt - self.amount_ct).zero?
    self.errors.add_to_base('Le volume ne doit pas être nul')
  end
end
