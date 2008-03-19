class AccountsController < ApplicationController
  before_filter :normalize_account_type, :only => %w(create update)

  def index
    @accounts = Account.paginate(:all, :order => 'no', :page => params[:page])
  end

  def new
    @account = Account.new(:account_type => AccountType.asset)
  end

  def create
    @account = Account.new
    if @account.update_attributes(params[:account]) then
      if params[:commit] =~ /nouveau/i then
        redirect_to :action => :new
      else
        redirect_to :action => :index
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @account = Account.find_by_no(params[:account_no])
    raise ActiveRecord::RecordNotFound unless @account
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account]) then
      redirect_to :action => :index
    else
      render :action => 'edit'
    end
  end

  def txn_list
    @account = Account.find_by_no(params[:account_no])
    raise "Account not found by number: #{params[:account_no].inspect}" unless @account
    start_on = params[:filter_date].blank? ? Time.local(0).to_date : parse_date(params[:filter_date])
    end_on = params[:cutoff_date].blank? ? 3.years.from_now : parse_date(params[:cutoff_date])

    @txns = @account.transactions_between(start_on, end_on)

    initial_dt, initial_ct = @account.total_dt_volume(start_on - 1, true), @account.total_ct_volume(start_on - 1, true)
    if initial_dt > initial_ct then
      initial_dt, initial_ct = initial_dt - initial_ct, Money.empty
    else
      initial_ct, initial_dt = initial_ct - initial_dt, Money.empty
    end

    initial_balance_txn = Txn.new(:description_html => "Solde d'ouverture", :posted_on => start_on - 1)

    @txns.unshift(TxnAccount.new(:amount_dt => initial_dt, :amount_ct => initial_ct,
        :account => @account, :txn => initial_balance_txn))

    @force = params[:force]
    @total = Money.empty
    @calculator =   if @account.debitor? then
                      Proc.new {|total, line| total + line.amount_dt - line.amount_ct }
                    else
                      Proc.new {|total, line| total + line.amount_ct - line.amount_dt }
                    end
    render :layout => false
  end

  protected
  def normalize_account_type
    params[:account][:account_type] = AccountType.new(params[:account][:account_type]) if params[:account]
  end
end
