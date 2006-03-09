class InvoicePayment < ActiveRecord::Base
  set_table_name :invoices_payments
  belongs_to :invoice
  belongs_to :payment
  validates_presence_of :invoice_id, :payment_id, :amount
  composed_of :amount_cents, :class_name => 'Money', :mapping => %w(amount_cents cents)

  def no=(no)
    self.invoice = Invoice.find_by_no(no)
  end

  def no
    self.invoice.no
  end

  def received_on
    self.payment.received_on
  end

  def amount
    self.amount_cents
  end

  def amount=(amount)
    self.amount_cents = amount.to_money
  end
end
