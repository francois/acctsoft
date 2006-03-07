class Customer < ActiveRecord::Base
  has_many :invoices
  validates_presence_of :name, :abbreviation
  validates_uniqueness_of :abbreviation
  validates_length_of :abbreviation, :maximum => 8
  composed_of :address, :mapping => [
                %w(address_line1 line1),
                %w(address_line2 line2),
                %w(address_line3 line3),
                %w(address_city city),
                %w(address_state state),
                %w(address_zip zip),
                %w(address_country country)]

  before_validation :normalize_abbreviation

  protected
  def normalize_abbreviation
    self.abbreviation = self.abbreviation.upcase unless self.abbreviation.blank?
  end
end
