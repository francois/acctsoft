class CheckDistribution < ActiveRecord::Base
  acts_as_list
  belongs_to :account
  belongs_to :check
  composed_of :amount_dt, :class_name => 'Money',
      :mapping => [%w(amount_dt_cents cents), %w(amount_dt_currency currency)]
  composed_of :amount_ct, :class_name => 'Money',
      :mapping => [%w(amount_ct_cents cents), %w(amount_ct_currency currency)]

  validates_presence_of :check_id, :account_id
  validates_uniqueness_of :account_id, :scope => :check_id
  before_validation DebitCreditNormalizer.new
end
