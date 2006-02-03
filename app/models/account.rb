class Account < ActiveRecord::Base
  validates_presence_of :no, :name, :account_type
  validates_inclusion_of :no, :in => (1 .. 999999)
  validates_uniqueness_of :no

  belongs_to :account_type, :class_name => 'AccountType', :foreign_key => 'type_id'

  def to_param
    self.no
  end
end
