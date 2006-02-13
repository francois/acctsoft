class Txn < ActiveRecord::Base
  validates_presence_of :posted_on, :description

  has_many :lines,  :class_name => 'TxnAccount', :order => 'position',
                    :dependent => true

  composed_of :volume, :class_name => 'Money',
      :mapping => [%w(volume_cents cents), %w(volume_currency currency)]

  before_validation :update_posted_on
  validate Proc.new {|txn|
    msg = 'Transaction is not balanced - check total of debits and credits'
    txn.errors.add_to_base(msg) unless txn.balanced?
  }

  def after_initialize
    self.posted_on = Date.today unless self.posted_on
  end

  def balanced?
    self.volume_dt == self.volume_ct
  end

  def volume_dt
    self.lines.inject(Money.empty) { |volume, line| volume + line.amount_dt }
  end

  def volume_ct
    self.lines.inject(Money.empty) { |volume, line| volume + line.amount_ct }
  end

  alias_method :volume, :volume_dt

  protected
  def update_posted_on
    self.posted_on = Date.today unless self.posted_on
  end
end
