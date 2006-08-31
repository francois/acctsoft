class ReportsController < ApplicationController
  before_filter :process_cutoff_date

  def index
    self.bilan
  end

  def txn_list
    @transactions = Txn.find(:all, :conditions => ['posted_on <= ?', @cutoff_date],
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
    @product_accounts = Account.find(:all, :conditions => ['type_id IN (?)', AccountType.produits.map(&:id)], :order => 'no')
    @charge_accounts  = Account.find(:all, :conditions => ['type_id IN (?)', AccountType.charges.map(&:id)], :order => 'no')

    @total_products_amount = @product_accounts.inject(Money.empty) {|sum, accnt| sum + accnt.total_ct_volume(@cutoff_date) - accnt.total_dt_volume(@cutoff_date) }
    @total_charges_amount = @charge_accounts.inject(Money.empty) {|sum, accnt| sum + accnt.total_dt_volume(@cutoff_date) - accnt.total_ct_volume(@cutoff_date) }
  end

  def avoir_proprietaire
    @avoir_accounts = Account.find(:all, :conditions => ['type_id IN (?) AND no NOT IN (?)',
        AccountType.avoirs.map {|at| at.id}, [3100, 3200]], :order => 'no')
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

    @actifs_accounts  = Account.find(:all, :conditions => ['type_id IN (?)', AccountType.actifs.map {|at| at.id}], :order => 'no')
    @total_actifs = @actifs_accounts.inject(Money.empty) {|total, accnt| total + accnt.total_dt_volume(@cutoff_date) - accnt.total_ct_volume(@cutoff_date) }

    @passifs_accounts = Account.find(:all, :conditions => ['type_id IN (?)', AccountType.passifs.map {|at| at.id}], :order => 'no')
    @total_passifs = @passifs_accounts.inject(Money.empty) {|total, accnt| total + accnt.total_ct_volume(@cutoff_date) - accnt.total_dt_volume(@cutoff_date) }

    @avoir = @avoir_accounts.first
    @avoir.readonly!
    @avoir.total_ct_volume = @end_amount
    @avoir.total_dt_volume = Money.empty

    @total_avoirs = @avoir_accounts.inject(Money.empty) {|total, accnt| total + accnt.total_ct_volume(@cutoff_date) - accnt.total_dt_volume(@cutoff_date) }

    render :layout => !params[:component], :action => 'bilan'
  end

  protected
  def process_cutoff_date
    session[:cutoff_date] = @cutoff_date =
        if params[:cutoff_date].blank? then
          session[:cutoff_date] || Date.today
        else
          parse_date(params[:cutoff_date])
        end
  end
end
