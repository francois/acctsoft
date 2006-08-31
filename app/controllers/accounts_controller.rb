class AccountsController < ApplicationController
  def index
    @accounts = Account.find(:all, :order => 'no')
  end

  def new
    @account = Account.new
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
    if @account.update_attributes(params[:account_no]) then
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
    @force = params[:force]

    @total = Money.empty
    @calculator =   case
                    when  AccountType.actifs.include?(@account.account_type),
                          AccountType.charges.include?(@account.account_type),
                          AccountType.avoirs.include?(@account.account_type)
                      Proc.new {|total, line| total + line.amount_dt - line.amount_ct }
                    else
                      Proc.new {|total, line| total + line.amount_ct - line.amount_dt }
                    end
    render :layout => false
  end
end
