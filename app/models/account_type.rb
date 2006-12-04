class AccountType < ActiveRecord::Base
  acts_as_list

  validates_presence_of :name, :designation
  validates_length_of :name, :minimum => 1
  validates_inclusion_of :designation, :in => %w(actif passif produit charge avoir)

  DEBITORS = %w(actif charge)
  CREDITORS = %w(passif produit avoir)

  def normally_debitor?
    DEBITORS.include?(self.designation)
  end

  def normally_creditor?
    CREDITORS.include?(self.designation)
  end

  def self.actifs
    self.find_all_by_designation('actif')
  end

  def self.passifs
    self.find_all_by_designation('passif')
  end

  def self.avoirs
    self.find_all_by_designation('avoir')
  end

  def self.produits
    self.find_all_by_designation('produit')
  end

  def self.charges
    self.find_all_by_designation('charge')
  end

  def self.for_select
    self.find(:all, :order => 'position')
  end
end
