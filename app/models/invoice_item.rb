class InvoiceItem < ActiveRecord::Base
  acts_as_list :scope => :invoice_id
  belongs_to :invoice
  belongs_to :item
  validates_presence_of :invoice_id, :item_id, :quantity, :unit_price
  acts_as_decimal :quantity, :decimals => 3, :rounding => :ceil
  composed_of :unit_amount, :class_name => 'Money', :mapping => %w(unit_price_cents cents)

  def item_no
    self.item.no
  end

  def item_no=(no)
    self.item = Item.find_by_no(no)
  end

  def account
    self.item.charge_account
  end

  alias_method :original_quantity=, :quantity=
  def quantity=(qty)
    self.original_quantity = qty.blank? ? 1 : qty
  end

  def description
    read_attribute(:description) || self.item.description
  end

  def description=(desc)
    write_attribute(:description, desc.blank? ? nil : desc)
  end

  def unit_price
    self.unit_amount
  end

  def unit_price=(amount)
    self.unit_amount = amount.to_money
  end

  def extension_price
    (self.unit_price * self.quantity).ceil
  end
end
