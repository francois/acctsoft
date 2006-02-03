class AccountType < ActiveRecord::Base
  acts_as_list

  validates_presence_of :name, :designation
  validates_length_of :name, :minimum => 1
  validates_inclusion_of :designation, :in => %w(actif passif produit charge avoir)
end
