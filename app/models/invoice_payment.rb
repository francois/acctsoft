class InvoicePayment < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :payment
  validates_presence_of :invoice_id, :payment_id, :amount_cents
  acts_as_money :amount, :allow_nil => false

  def no=(no)
    self.invoice = Invoice.find_by_no(no)
  end

  def no
    self.invoice.no
  end

  def received_on
    self.payment.received_on
  end
end
