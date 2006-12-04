class Account < ActiveRecord::Base
  has_many :txn_parts, :class_name => 'TxnAccount', :include => :txn, :order => 'txns.posted_on, txns.id'

  validates_presence_of :no, :name
  validates_inclusion_of :no, :in => (1 .. 999999)
  validates_uniqueness_of :no
  composed_of :account_type, :mapping => %w(account_type designation)

  def total_dt_volume(cutoff_date=Date.today, force=false)
    load_total_from_cache(cutoff_date, force)
    @total_dt_volume
  end

  def total_ct_volume(cutoff_date=Date.today, force=false)
    load_total_from_cache(cutoff_date, force)
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

  def balance(force=false)
    amount_dt = self.total_dt_volume(Date.today, force)
    amount_ct = self.total_ct_volume(Date.today, force)
    self.debitor? ? amount_dt - amount_ct : amount_ct - amount_dt
  end

  def debitor?
    self.account_type.debitor?
  end

  def creditor?
    self.account_type.creditor?
  end

  def transactions_between(start_on, end_on)
    self.txn_parts.find(:all,
        :conditions => ['txns.posted_on BETWEEN :start_on AND :end_on',
            {:start_on => start_on, :end_on => end_on}])
  end

  def transactions_on_or_before(cutoff_date)
    conditions = ['txns.posted_on <= ?', cutoff_date] if cutoff_date
    self.txn_parts.find(:all, :conditions => conditions)
  end

  def to_param
    self.no.to_s
  end

  protected
  def load_total_from_cache(cutoff_date, force=false)
    return if @force_dt_total and @force_ct_total
    return if !force && cutoff_date == @total_volume_cutoff_date
    results = self.class.connection.select_one("
      SELECT SUM(amount_dt_cents) / 100 AS total_dt_volume, SUM(amount_ct_cents) / 100 AS total_ct_volume
      FROM txn_accounts INNER JOIN txns ON txns.id = txn_accounts.txn_id
      WHERE txns.posted_on <= '#{cutoff_date.to_date.to_s(:db)}' AND txn_accounts.account_id = #{self.id} ")

    @total_dt_volume = results['total_dt_volume'].to_money unless @force_dt_total
    @total_ct_volume = results['total_ct_volume'].to_money unless @force_ct_total
    @total_volume_cutoff_date = cutoff_date
  end
end
