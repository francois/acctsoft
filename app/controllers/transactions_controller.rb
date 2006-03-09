class TransactionsController < ApplicationController
  before_filter :parse_dates

  def index
    @transaction_pages, @transactions = paginate(:txn, :per_page => 30, :order => 'posted_on DESC, id DESC')
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
    @transaction = Txn.find(params[:id])

    params[:txn_account].each do |id, attrs|
      @transaction.lines.find(id).update_attributes(attrs)
    end

    if @transaction.update_attributes(params[:transaction]) then
      @transaction.destroy unless params[:destroy].blank?
      redirect_to :action => :index
    else
      @editable = false
      render :action => 'edit'
    end
  end

  def auto_complete_for_account_no
    @accounts = Account.find(:all, :order => 'no', :limit => 20,
        :conditions => ['no LIKE :no OR name LIKE :no OR description LIKE :no',
            {:no => "#{params[:account][:no]}%"}])
    render :layout => false
  end

  def add_account
    @txn_account = TxnAccount.new(params[:account])
    @txn_line_count = 1 + params[:txn][:line_count].to_i
    @editable = true
  end

  protected
  def parse_dates
    return unless params[:transaction]
    params[:transaction][:posted_on] = parse_date(params[:transaction][:posted_on])
  end
end
