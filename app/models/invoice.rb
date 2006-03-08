class Invoice < ActiveRecord::Base
  belongs_to :customer
  belongs_to :txn
  has_many :payments, :class_name => 'InvoicePayment'
  has_many :lines, :class_name => 'InvoiceItem'
  validates_presence_of :no, :customer, :invoiced_on
  validates_numericality_of :no

  def after_initialize
    self.invoiced_on = Date.today if self.invoiced_on.blank?
  end

  def total
    self.lines.inject(0.to_money) {|sum, line| sum + line.extension_price}
  end

  def paid
    self.payments.inject(0.to_money) {|sum, payment| sum + payment.amount}
  end

  def balance
    self.total - self.paid
  end

  def to_param
    self.no
  end

  def post!(now=Time.now)
    self.transaction do
      ar_account = AccountConfiguration.get('Comptes Clients')

      lines = Hash.new
      self.lines.each do |line|
        lines[line.account] ||= 0.to_money
        lines[line.account] += line.extension_price
      end

      lines = lines.to_a.sort_by {|line| line.first.no}

      self.txn = Txn.new
      self.txn.posted_on = self.invoiced_on
      self.txn.description = "Facture #{self.no}"

      self.txn.lines.build(:account => ar_account, :amount_dt => self.total)
      lines.each do |account, amount|
        self.txn.lines.build(:account => account, :amount_ct => amount)
      end
      self.txn.save!

      self.posted_at = now
      self.save!
    end
  end
end
