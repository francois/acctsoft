class Account < ActiveRecord::Base
  validates_presence_of :no, :name, :type
  validates_inclusion_of :no, :in => (1 .. 999999)
end
