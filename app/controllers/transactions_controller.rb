class TransactionsController < ApplicationController
  def index
    @transaction_pages, @transactions = paginate(:txn, :per_page => 30, :order => 'posted_on DESC, id DESC')
  end

  def new
    @transaction = Txn.new
    self.count_lines! if request.get?
    update_and_redirect('new') if request.post?
  end

  def edit
    @transaction = Txn.find(params[:txn])
    self.count_lines! if request.get?
    update_and_redirect('edit') if request.post?
  end

  def add_line
    render(:nothing => true) if params[:nline][:no].blank?
    @line = TxnAccount.new(params[:nline])
    @line_count = 1 + params[:line_count].to_i
    render :layout => false
  end

  def delete_line
    @transaction = Txn.find(params[:transaction])
    @line = @transaction.lines.find(params[:line])
    @line.destroy
    self.count_lines!
    @index = params[:index]
  end

  protected
  def update_and_redirect
    self.parse_dates
    if params[:line] then
      params[:line].each do |id, values|
        @line = @transaction.lines.find(id) rescue @transaction.lines.build
        if @line.new_record? then
          @line.attributes = values
        else
          unless @line.update_attributes(values) then
            flash_failure :now, "Compte #{values[:no]}: #{@line.errors.full_messages.join(', ')}"
          end
        end
      end
    end

    if @transaction.update_attributes(params[:transaction]) then
      if params[:commit] =~ /nouveau/i then
        redirect_to :action => :new
      else
        redirect_to :action => :index
      end
    end
  end

  def count_lines!
    return @transaction.lines.count if @transaction.new_record?
    count = TxnAccount.connection.select_value("SELECT MAX(id) FROM #{TxnAccount.table_name} WHERE txn_id = #{@transaction.id}")
    @line_count = count.to_i rescue 0
  end

  def parse_dates
    return unless params[:transaction]
    params[:transaction][:posted_on] = parse_date(params[:transaction][:posted_on])
  end
end
