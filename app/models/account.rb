class Account < ActiveRecord::Base
  has_many :txn_parts, :class_name => 'TxnAccount', :include => :txn, :order => 'txns.posted_on, txns.id'

  validates_presence_of :no, :name, :account_type
  validates_inclusion_of :no, :in => (1 .. 999999)
  validates_uniqueness_of :no

  belongs_to :account_type, :class_name => 'AccountType', :foreign_key => 'type_id'

  def total_dt_volume(cutoff_date=Date.today)
    load_total_from_cache(cutoff_date)
    @total_dt_volume
  end

  def total_ct_volume(cutoff_date=Date.today)
    load_total_from_cache(cutoff_date)
    @total_ct_volume
  end

  def total_dt_volume=(dt_amount)
    @total_dt_volume = dt_amount
    @force_dt_total = true
  end

  def total_ct_volume=(ct_amount)
    @total_ct_volume = ct_amount
    @force_ct_total = true
  end

  def normally_debitor?
    !normally_creditor?
  end

  def normally_creditor?
    (AccountType.passifs + AccountType.avoirs + AccountType.produits).flatten.include?(self.account_type)
  end

  def to_param
    self.no
  end

  protected
  def load_total_from_cache(cutoff_date)
    return if @force_dt_total and @force_ct_total
    return if cutoff_date == @total_volume_cutoff_date
    results = self.class.connection.select_one("
      SELECT SUM(amount_dt_cents) / 100 AS total_dt_volume, SUM(amount_ct_cents) / 100 AS total_ct_volume
      FROM txn_accounts INNER JOIN txns ON txns.id = txn_accounts.txn_id
      WHERE txns.posted_on <= '#{cutoff_date.to_time.strftime('%Y-%m-%d')}' AND txn_accounts.account_id = #{self.id} ")

    @total_dt_volume = results['total_dt_volume'].to_money unless @force_dt_total
    @total_ct_volume = results['total_ct_volume'].to_money unless @force_ct_total
    @total_volume_cutoff_date = cutoff_date
  end
end
