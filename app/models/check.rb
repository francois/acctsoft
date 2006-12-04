class Check < ActiveRecord::Base
  belongs_to :bank_account, :class_name => 'Account', :foreign_key => 'bank_account_id'
  belongs_to :txn
  composed_of :amount, :class_name => 'Money', :mapping => [%w(amount_cents cents), %w(amount_currency currency)]
  has_many :distributions, :class_name => 'CheckDistribution', :order => 'position'

  validates_uniqueness_of :no
  validates_presence_of :no, :date, :beneficiary, :reason, :bank_account_id, :amount_cents
  before_validation :add_bank_account_line
  validate :amount_balances_with_distribution

  def transfer!
    self.class.transaction do
      self.save! if self.new_record?
      self.txn = Txn.create!(:description => "Chèque \##{self.no}: #{self.reason}", :posted_on => self.date)
      self.distributions(true).each do |distribution|
        self.txn.lines.create!(:account => distribution.account,
            :amount_dt => distribution.amount_dt,
            :amount_ct => distribution.amount_ct)
      end

      self.txn.save!
      self.save!
    end
  end

  protected
  def amount_balances_with_distribution
    partial_distribution = self.distributions.reject {|d| d.account == self.bank_account}
    partial_amount = partial_distribution.map(&:amount_dt).sum - partial_distribution.map(&:amount_ct).sum
    return if self.amount == partial_amount
    self.errors.add(:amount, "ne correspond pas à la distribution (#{self.amount} != #{partial_amount})")
  end

  def add_bank_account_line
    distribution = self.distributions.select {|d| d.account == self.bank_account}.first
    distribution = self.distributions.build(:account => self.bank_account) unless distribution
    distribution.amount_ct = self.amount
    distribution.amount_dt = Money.zero
    distribution.save unless self.new_record?
    true # Don't stop validation all of a sudden
  end
end
