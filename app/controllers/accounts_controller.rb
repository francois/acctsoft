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
      render 'new'
    end
  end

  def edit
    @account = Account.find_by_no(params[:account])
    raise ActiveRecord::RecordNotFound unless @account
  end

  def update
    @account = Account.find(params[:id])
    if @account.update_attributes(params[:account]) then
      redirect_to :action => :index
    else
      render 'edit'
    end
  end

  def txn_list
    @account = Account.find_by_no(params[:account])
    @txns = @account.transactions_on_or_before(parse_date(params[:cutoff_date]))
    @force = params[:force]

    @total = Money.empty
    @calculator =   case
                    when AccountType.actifs.include?(@account.account_type), AccountType.produits.include?(@account.account_type)
                      Proc.new {|total, line| total + line.amount_dt - line.amount_ct }
                    else
                      Proc.new {|total, line| total + line.amount_ct - line.amount_dt }
                    end
    render :layout => false
  end
end
