class TransactionsController < ApplicationController
  def index
    @transaction_pages, @transactions = paginate(:txn, :per_page => 30, :order => 'posted_on DESC')
  end

  def new
    @transaction = Txn.new
    @txn_line_count = @transaction.lines.count
    @editable = true
  end

  def create
    @transaction = Txn.new(params[:transaction])
    params[:txn_account].sort.each do |k, v|
      @transaction.lines.build(v)
    end

    if @transaction.save then
      if params[:commit] =~ /nouveau/i then
        redirect_to :action => :new
      else
        redirect_to :action => :index
      end
    else
      @editable = true
      render :action => 'new'
    end
  end

  def edit
    @transaction = Txn.find(params[:id])
    @txn_line_count = @transaction.lines.count
    @editable = false
  end

  def update
  end

  def auto_complete_for_account_no
    @accounts = Account.find(:all, :order => 'no', :limit => 20,
        :conditions => ['no LIKE ?', "#{params[:account][:no]}%"])
    render :layout => false
  end

  def add_account
    @txn_account = TxnAccount.new(params[:account])
    @txn_line_count = 1 + params[:txn][:line_count].to_i
    @editable = true
  end
end
