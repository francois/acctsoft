class Company < ActiveRecord::Base
  validates_presence_of :name, :year
  validates_inclusion_of :year, :in => (2000 .. 9999)
end
