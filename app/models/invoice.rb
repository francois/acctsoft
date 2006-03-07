class Invoice < ActiveRecord::Base
  belongs_to :customer
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
end
