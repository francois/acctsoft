class Payment < ActiveRecord::Base
  belongs_to :customer
  belongs_to :txn
  has_many :invoices, :class_name => 'InvoicePayment', :dependent => :destroy
  validates_presence_of :customer_id, :amount, :reference, :received_on
  composed_of :amount_cents, :class_name => 'Money', :mapping => %w(amount_cents cents)

  def after_initialize
    self.received_on = Date.today unless self.received_on
  end

  def amount
    self.amount_cents
  end

  def amount=(amount)
    self.amount_cents = amount.to_money
  end

  def total_paid
    self.invoices.inject(0.to_money) {|sum, invoice| sum + invoice.amount}
  end

  def can_upload?
    self.total_paid == self.amount && !self.txn
  end

  def post!(now=Time.now)
    self.transaction do
      raise "Invalid state - cannot upload" unless self.can_upload?
      ar_account = AccountConfiguration.get('Comptes Clients')
      encaisse_account = AccountConfiguration.get('Encaisse')

      self.txn = Txn.new
      self.txn.posted_on = self.received_on
      self.txn.description = "Encaissement facture#{'s' if self.invoices.size > 1} #{self.invoices.map {|i| i.no}.to_sentence}."
      self.txn.lines.build(:account => encaisse_account, :amount_dt => self.amount)
      self.txn.lines.build(:account => ar_account, :amount_ct => self.amount)
      self.txn.save!

      self.posted_at = now
      self.save!
    end
  end
end
