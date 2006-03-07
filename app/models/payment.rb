class Payment < ActiveRecord::Base
  belongs_to :customer
  has_many :invoices, :class_name => 'InvoicePayment'
  validates_presence_of :customer, :amount, :reference, :paid_on, :received_on
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
    self.total_paid == self.amount
  end
end
