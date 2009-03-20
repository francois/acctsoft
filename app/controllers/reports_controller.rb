class ReportsController < ApplicationController
  before_filter :process_cutoff_date

  def index
    self.bilan
  end

  def txn_list
    @transactions = Txn.find(:all, :conditions => ['posted_on BETWEEN ? AND ?', @filter_date, @cutoff_date],
        :order => 'posted_on, updated_at')
  end

  def general_ledger
    @accounts = Account.find(:all, :order => 'no')
  end

  def balance_verification
    @accounts = Account.find(:all, :order => 'no')

    @total_dt_volume = @accounts.inject(Money.empty) {|sum, account| sum + account.total_dt_volume(@cutoff_date) }
    @total_ct_volume = @accounts.inject(Money.empty) {|sum, account| sum + account.total_ct_volume(@cutoff_date) }
  end

  def etat_resultats
    @product_accounts = Account.find(:all, :conditions => ['account_type IN (?)', AccountType.incomes], :order => 'no')
    @charge_accounts  = Account.find(:all, :conditions => ['account_type IN (?)', AccountType.expenses], :order => 'no')

    @total_products_amount = @product_accounts.inject(Money.empty) {|sum, accnt| sum + accnt.total_ct_volume(@cutoff_date) - accnt.total_dt_volume(@cutoff_date) }
    @total_charges_amount = @charge_accounts.inject(Money.empty) {|sum, accnt| sum + accnt.total_dt_volume(@cutoff_date) - accnt.total_ct_volume(@cutoff_date) }
  end

  def avoir_proprietaire
    @avoir_accounts = Account.find(:all, :conditions => ['account_type IN (?) AND no NOT IN (?)',
        AccountType.equities, [3100, 3200]], :order => 'no')
    @initial_amount = @avoir_accounts.inject(Money.empty) {|sum, accnt| sum + accnt.total_ct_volume(@cutoff_date) } - @avoir_accounts.inject(Money.empty) {|sum, accnt| sum + accnt.total_dt_volume(@cutoff_date) }

    self.etat_resultats

    @additions      = Account.find_by_no(3200).total_ct_volume(@cutoff_date) - Account.find_by_no(3200).total_dt_volume(@cutoff_date)
    @substractions  = Account.find_by_no(3100).total_dt_volume(@cutoff_date) - Account.find_by_no(3100).total_ct_volume(@cutoff_date)

    @benefit = @loss = Money.empty
    if @total_products_amount > @total_charges_amount then
      @benefit = @total_products_amount - @total_charges_amount
    else
      @loss = @total_charges_amount - @total_products_amount
    end

    @end_amount = @initial_amount + @additions + @benefit - @substractions - @loss
  end

  def bilan
    self.avoir_proprietaire

    @actifs_accounts  = Account.find(:all, :conditions => ['account_type IN (?)', AccountType.assets], :order => 'no')
    @total_actifs = @actifs_accounts.inject(Money.empty) {|total, accnt| total + accnt.total_dt_volume(@cutoff_date) - accnt.total_ct_volume(@cutoff_date) }

    @passifs_accounts = Account.find(:all, :conditions => ['account_type IN (?)', AccountType.liabilities], :order => 'no')
    @total_passifs = @passifs_accounts.inject(Money.empty) {|total, accnt| total + accnt.total_ct_volume(@cutoff_date) - accnt.total_dt_volume(@cutoff_date) }

    @avoir = @avoir_accounts.first
    @avoir.readonly!
    @avoir.total_ct_volume = @end_amount
    @avoir.total_dt_volume = Money.empty

    @total_avoirs = @avoir_accounts.inject(Money.empty) {|total, accnt| total + accnt.total_ct_volume(@cutoff_date) - accnt.total_dt_volume(@cutoff_date) }

    render :layout => !params[:component], :action => 'bilan'
  end

  def invoicing
    @invoices = Invoice.all(:conditions => {:invoiced_on => (@filter_date .. @cutoff_date)})

    @subtotal = @invoices.map(&:subtotal).sum(Money.zero)
    @gst      = @invoices.map(&:gst).sum(Money.zero)
    @pst      = @invoices.map(&:pst).sum(Money.zero)
    @total    = @invoices.map(&:total).sum(Money.zero)

    render :layout => !params[:component]
  end

  protected
  def process_cutoff_date
    session[:cutoff_date] = @cutoff_date =
        if params[:cutoff_date].blank? then
          session[:cutoff_date] || Date.today
        else
          parse_date(params[:cutoff_date])
        end
    session[:filter_date] = @filter_date =
        if params[:filter_date].blank? then
          session[:filter_date] || Time.now.at_beginning_of_year.to_date
        else
          parse_date(params[:filter_date])
        end
  end
end
