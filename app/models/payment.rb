class Payment < ActiveRecord::Base
  belongs_to :customer
  belongs_to :txn
  has_many :invoices, :class_name => 'InvoicePayment', :dependent => :destroy
  validates_presence_of :customer_id, :amount_cents, :reference, :received_on
  acts_as_money :amount, :allow_nil => false

  def after_initialize
    self.received_on = Date.today unless self.received_on
  end

  def total_paid
    self.invoices.inject(0.to_money) {|sum, invoice| sum + invoice.amount}
  end

  def balanced?
    self.total_paid == self.amount
  end

  def can_upload?
    !self.txn
  end

  def post!(target_account, now=Time.now)
    self.class.transaction do
      raise "Invalid state - cannot upload" unless self.can_upload?
      ar_account = AccountConfiguration.get('Comptes Clients')

      self.txn = Txn.new
      self.txn.posted_on = self.received_on
      self.txn.description = "Encaissement facture#{'s' if self.invoices.size > 1} \##{self.invoices.map {|i| i.no}.to_sentence}."
      self.txn.lines.build(:account => target_account, :amount_dt => self.amount)
      self.txn.lines.build(:account => ar_account, :amount_ct => self.amount)
      self.txn.save!

      self.posted_at = now
      self.save!
    end
  end
end
