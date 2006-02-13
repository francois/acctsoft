class ReportsController < ApplicationController
  def index
    self.bilan
    render :action => 'bilan'
  end

  def balance_verification
    @accounts = Account.find(:all, :order => 'no')

    @total_dt_volume = @accounts.inject(Money.empty) {|sum, account| sum + account.total_dt_volume}
    @total_ct_volume = @accounts.inject(Money.empty) {|sum, account| sum + account.total_ct_volume}
  end

  def etat_resultats
    @product_accounts = Account.find(:all, :conditions => ['type_id IN (?)', AccountType.produits.map {|at| at.id}], :order => 'no')
    @charge_accounts  = Account.find(:all, :conditions => ['type_id IN (?)', AccountType.charges.map {|at| at.id}], :order => 'no')

    @total_products_amount = @product_accounts.inject(Money.empty) {|sum, accnt| sum + accnt.total_ct_volume - accnt.total_dt_volume}
    @total_charges_amount = @charge_accounts.inject(Money.empty) {|sum, accnt| sum + accnt.total_dt_volume - accnt.total_ct_volume}
  end

  def avoir_proprietaire
    @avoir_accounts = Account.find(:all, :conditions => ['type_id IN (?) AND no NOT IN (?)',
        AccountType.avoirs.map {|at| at.id}, [3100, 3200]], :order => 'no')
    @initial_amount = @avoir_accounts.inject(Money.empty) {|sum, accnt| sum + accnt.total_ct_volume} - @avoir_accounts.inject(Money.empty) {|sum, accnt| sum + accnt.total_dt_volume}

    self.etat_resultats

    @additions      = Account.find_by_no(3200).total_ct_volume - Account.find_by_no(3200).total_dt_volume
    @substractions  = Account.find_by_no(3100).total_dt_volume - Account.find_by_no(3100).total_ct_volume

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
    @total_actifs = @actifs_accounts.inject(Money.empty) {|total, accnt| total + accnt.total_dt_volume - accnt.total_ct_volume }

    @passifs_accounts = Account.find(:all, :conditions => ['type_id IN (?)', AccountType.passifs.map {|at| at.id}], :order => 'no')
    @total_passifs = @passifs_accounts.inject(Money.empty) {|total, accnt| total + accnt.total_ct_volume - accnt.total_dt_volume }

    @avoir = @avoir_accounts.first
    @avoir.readonly!
    @avoir.total_ct_volume = @end_amount
    @avoir.total_dt_volume = Money.empty

    @total_avoirs = @avoir_accounts.inject(Money.empty) {|total, accnt| total + accnt.total_ct_volume - accnt.total_dt_volume }
  end
end
