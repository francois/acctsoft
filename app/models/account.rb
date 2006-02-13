class Account < ActiveRecord::Base
  has_many :txn_parts, :class_name => 'TxnAccount'

  validates_presence_of :no, :name, :account_type
  validates_inclusion_of :no, :in => (1 .. 999999)
  validates_uniqueness_of :no

  belongs_to :account_type, :class_name => 'AccountType', :foreign_key => 'type_id'

  def total_dt_volume
    return @total_dt_volume if @total_dt_volume
    self.txn_parts.inject(Money.empty) {|sum, txn_account|
      sum + txn_account.amount_dt
    }
  end

  def total_ct_volume
    return @total_ct_volume if @total_ct_volume
    self.txn_parts.inject(Money.empty) {|sum, txn_account|
      sum + txn_account.amount_ct
    }
  end

  def total_dt_volume=(dt_amount)
    @total_dt_volume = dt_amount
  end

  def total_ct_volume=(ct_amount)
    @total_ct_volume = ct_amount
  end

  def to_param
    self.no
  end
end
