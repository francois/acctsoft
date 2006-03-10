class ImportExistingInvoicesAndPayments < ActiveRecord::Migration
  class AccountConfiguration < ActiveRecord::Base
    validates_presence_of :name, :account_no
    validates_length_of :name, :minimum => 1
    validates_numericality_of :account_no

    attr_accessible :account_no

    def account
      account = Account.find_by_no(self.account_no)
      raise ActiveRecord::RecordNotFound, "Could not find account #{self.account_no} (#{self.name})" \
          unless account
      account
    end

    def self.get(name)
      ac = self.find_by_name(name)
      raise ActiveRecord::RecordNotFound, "Could not find account named #{name.inspect}" unless ac
      raise ActiveRecord::RecordInvalid, "Account #{name.inspect} is not configuration" unless ac.account
      ac.account
    end
  end

  class Item < ActiveRecord::Base
    validates_presence_of :no, :charge_account_no, :description
    validates_numericality_of :no

    def charge_account
      Account.find_by_no(self.charge_account_no)
    end
  end

  class Customer < ActiveRecord::Base
    has_many :invoices, :class_name => 'ImportExistingInvoicesAndPayments::Invoice'
    validates_presence_of :name, :abbreviation
    validates_uniqueness_of :abbreviation
    validates_length_of :abbreviation, :maximum => 8

    def self.get(abbreviation)
      customer = self.find_by_abbreviation(abbreviation)
      raise ActiveRecord::RecordNotFound, "No customer with abbreviation #{abbreviation.inspect}" unless customer
      customer
    end
  end

  class Invoice < ActiveRecord::Base
    belongs_to :customer, :class_name => 'ImportExistingInvoicesAndPayments::Customer'
    belongs_to :txn, :class_name => 'ImportExistingInvoicesAndPayments::Txn'
    has_many :payments, :class_name => 'ImportExistingInvoicesAndPayments::InvoicePayment'
    has_many :lines, :class_name => 'ImportExistingInvoicesAndPayments::InvoiceItem', :dependent => :destroy
    validates_presence_of :no, :customer_id, :invoiced_on
    validates_numericality_of :no

    def total
      self.lines.inject(0.to_money) {|sum, line| sum + line.extension_price}
    end

    def post!(now=Time.now)
      self.transaction do
        ar_account = AccountConfiguration.get('Comptes Clients')

        lines = Hash.new
        self.lines.each do |line|
          lines[line.account] ||= 0.to_money
          lines[line.account] += line.extension_price
        end

        lines = lines.to_a.sort_by {|line| line.first.no}

        self.txn = Txn.new
        self.txn.posted_on = self.invoiced_on
        self.txn.description = "Facture #{self.no}"

        self.txn.lines.build(:account => ar_account, :amount_dt => self.total)
        lines.each do |account, amount|
          self.txn.lines.build(:account => account, :amount_ct => amount)
        end
        self.txn.save!

        self.posted_at = now
        self.save!
      end
    end
  end

  class Payment < ActiveRecord::Base
    belongs_to :customer, :class_name => 'ImportExistingInvoicesAndPayments::Customer'
    belongs_to :txn, :class_name => 'ImportExistingInvoicesAndPayments::Txn'
    has_many :invoices, :class_name => 'ImportExistingInvoicesAndPayments::InvoicePayment', :dependent => :destroy
    validates_presence_of :customer_id, :amount, :reference, :received_on
    composed_of :amount_cents, :class_name => 'Money', :mapping => %w(amount_cents cents)

    def amount
      self.amount_cents
    end

    def amount=(amount)
      self.amount_cents = amount.to_money
    end

    def total_paid
      self.invoices.inject(0.to_money) {|sum, invoice| sum + invoice.amount}
    end

    def can_upload?
      self.total_paid == self.amount && !self.txn
    end

    def post!(now=Time.now)
      self.transaction do
        raise "Invalid state - cannot upload" unless self.can_upload?
        ar_account = AccountConfiguration.get('Comptes Clients')
        encaisse_account = AccountConfiguration.get('Encaisse')

        self.txn = Txn.new
        self.txn.posted_on = self.received_on
        self.txn.description = "Encaissement facture#{'s' if self.invoices.size > 1} #{self.invoices.map {|i| i.no}.to_sentence}."
        self.txn.lines.build(:account => encaisse_account, :amount_dt => self.amount)
        self.txn.lines.build(:account => ar_account, :amount_ct => self.amount)
        self.txn.save!

        self.posted_at = now
        self.save!
      end
    end
  end

  class InvoiceItem < ActiveRecord::Base
    acts_as_list :scope => :invoice_id
    belongs_to :invoice, :class_name => 'ImportExistingInvoicesAndPayments::Invoice'
    belongs_to :item, :class_name => 'ImportExistingInvoicesAndPayments::Item'
    validates_presence_of :invoice_id, :item_id, :quantity, :unit_price
    acts_as_decimal :quantity, :decimals => 3, :rounding => :ceil
    composed_of :unit_amount, :class_name => 'Money', :mapping => %w(unit_price_cents cents)

    def account
      self.item.charge_account
    end

    alias_method :original_quantity=, :quantity=
    def quantity=(qty)
      self.original_quantity = qty.blank? ? 1 : qty
    end

    def description
      read_attribute(:description) || self.item.description
    end

    def description=(desc)
      write_attribute(:description, desc.blank? ? nil : desc)
    end

    def unit_price
      self.unit_amount
    end

    def unit_price=(amount)
      self.unit_amount = amount.to_money
    end

    def extension_price
      (self.unit_price * self.quantity).ceil
    end
  end

  class InvoicePayment < ActiveRecord::Base
    belongs_to :invoice, :class_name => 'ImportExistingInvoicesAndPayments::Invoice'
    belongs_to :payment, :class_name => 'ImportExistingInvoicesAndPayments::Payment'
    validates_presence_of :invoice_id, :payment_id, :amount
    composed_of :amount_cents, :class_name => 'Money', :mapping => %w(amount_cents cents)

    def no=(no)
      self.invoice = Invoice.find_by_no(no)
    end

    def no
      self.invoice.no
    end

    def received_on
      self.payment.received_on
    end

    def amount
      self.amount_cents
    end

    def amount=(amount)
      self.amount_cents = amount.to_money
    end
  end

  class Txn < ActiveRecord::Base
    has_many :lines,  :class_name => 'ImportExistingInvoicesAndPayments::TxnAccount',
                      :order => 'position', :dependent => :delete_all
    before_save :format_description_html

    protected
    def format_description_html
      self.description_html = RedCloth.new(self.description).to_html
    end
  end

  class TxnAccount < ActiveRecord::Base
    acts_as_list

    belongs_to :txn, :class_name => 'ImportExistingInvoicesAndPayments::Txn'
    belongs_to :account, :class_name => 'ImportExistingInvoicesAndPayments::Account'
    validates_presence_of :account_id

    composed_of :amount_dt, :class_name => 'Money',
        :mapping => [%w(amount_dt_cents cents), %w(amount_dt_currency currency)]
    composed_of :amount_ct, :class_name => 'Money',
        :mapping => [%w(amount_ct_cents cents), %w(amount_ct_currency currency)]

    before_validation :normalize_amounts
    validate :non_nil_volume

    def no
      self.account.no
    end

    def no=(account_no)
      self.account = Account.find_by_no(account_no)
    end

    def name
      self.account.name
    end

    def debit=(amount)
      self.amount_dt = amount.to_money
    end

    def debit
      self.amount_dt
    end

    def credit=(amount)
      self.amount_ct = amount.to_money
    end

    def credit
      self.amount_ct
    end

    protected
    def normalize_amounts
      return if self.amount_dt.zero? or self.amount_ct.zero?
      if self.amount_dt > self.amount_ct then
        self.amount_dt -= self.amount_ct
        self.amount_ct = Money.empty
      else
        self.amount_ct -= self.amount_dt
        self.amount_dt = Money.empty
      end
    end

    def non_nil_volume
      return unless (self.amount_dt - self.amount_ct).zero?
      self.errors.add_to_base('Le volume ne doit pas être nul')
    end
  end

  class Account < ActiveRecord::Base; end

  def self.parse_date(date)
    return Date.new($1.to_i, $2.to_i, $3.to_i) if date =~ /\A(\d{4}).(\d{1,2}).(\d{1,2})\Z/
    nil
  end

  def self.up
    say_with_time('Preparing AccountConfiguration') do
      AccountConfiguration.find_by_name('Comptes Clients').update_attributes(:account_no => 1100)
      AccountConfiguration.find_by_name('Encaisse').update_attributes(:account_no => 1000)
      AccountConfiguration.find_by_name('TPS à recevoir').update_attributes(:account_no => 1510)
      AccountConfiguration.find_by_name('TVQ à recevoir').update_attributes(:account_no => 1520)
      AccountConfiguration.find_by_name('TPS à payer').update_attributes(:account_no => 2110)
      AccountConfiguration.find_by_name('TVQ à payer').update_attributes(:account_no => 2120)
    end

    say_with_time('Creating customers') do
      Customer.create!(:name => 'American Biltrite (Canada) Ltée', :abbreviation => 'AB')
      Customer.create!(:name => 'Acton International', :abbreviation => 'ACTON')
      Customer.create!(:name => 'W.B.C.', :abbreviation => 'WBC')
      Customer.create!(:name => 'Clud l\'Envolley de Sherbrooke', :abbreviation => 'ENVOLLEY')
      Customer.create!(:name => 'We Put Up Lights.com', :abbreviation => 'WPUL')
      Customer.create!(:name => 'IFWORLD Inc.', :abbreviation => 'IFWORLD')
      Customer.create!(:name => 'William Dale', :abbreviation => 'WILLIAM')
    end

    customers = {
        'American Biltrite (Canada) Ltée' => Customer.get('AB'),
        'Acton International' => Customer.get('ACTON'),
        'Wiz Beauty Care' => Customer.get('WBC'),
        'Club Envolley de Sherbrooke' => Customer.get('ENVOLLEY'),
        'W.B.C.' => Customer.get('WBC'),
        'We Put Lights Up.com' => Customer.get('WPUL'),
        'IFWORLD Inc.' => Customer.get('IFWORLD'),
        'William Dale' => Customer.get('WILLIAM')
    }

    say_with_time('Creating default items') do
      Item.create!(:no => 10, :description => 'Temps', :charge_account_no => 4010)
      Item.create!(:no => 20, :description => 'Hébergement', :charge_account_no => 4020)
      Item.create!(:no => 50, :description => 'TPS', :charge_account_no => 2110)
      Item.create!(:no => 60, :description => 'TVQ', :charge_account_no => 2120)
    end

    time = Item.find_by_no(10)
    gst = Item.find_by_no(50)
    pst = Item.find_by_no(60)

    say_with_time('Importing existing invoices') do
      CSV::open(File.join(RAILS_ROOT, 'db', 'migrate', 'facturation.csv'), 'rb') do |row|
        invoice_no = row[0]
        customer = customers[row[1]]
        invoiced_on = parse_date(row[2])
        subtotal_amount = row[3].to_money
        gst_amount = row[4].to_money
        pst_amount = row[5].to_money
        total_amount = row[6].to_money
        received_on = parse_date(row[8])

        raise "No invoiced_on for line #{row.inspect}" unless invoiced_on
        raise "No received_on for line #{row.inspect}" unless received_on or (received_on.blank? and row[8].blank?)

        say "Importing #{invoice_no}"
        invoice = customer.invoices.build(:no => invoice_no, :invoiced_on => invoiced_on)
        invoice.lines.build(:item => time, :quantity => 1, :unit_price => subtotal_amount) unless subtotal_amount.zero?
        invoice.lines.build(:item => gst, :quantity => 1, :unit_price => gst_amount) unless gst_amount.zero?
        invoice.lines.build(:item => pst, :quantity => 1, :unit_price => pst_amount) unless pst_amount.zero?

        begin
          if received_on then
            payment_line = invoice.payments.build(:amount => invoice.total)
            payment = payment_line.build_payment(:customer => invoice.customer, :received_on => received_on, :amount => invoice.total, :reference => 'import')
            payment.save!
          end

          invoice.save!
          invoice.post!

          invoice.payments.first.payment.post! unless invoice.payments.empty?
        rescue ActiveRecord::RecordInvalid
          puts "Error loading line #{row.inspect}"
          puts $!.inspect
        end
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
