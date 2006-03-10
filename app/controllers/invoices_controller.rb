class InvoicesController < ApplicationController
  def index
    @invoices = Invoice.find(:all, :order => 'no DESC')
  end

  def new
    @inv = Invoice.new
    self.count_lines! if request.get?
    update_and_redirect if request.post?
  end

  def edit
    @inv = Invoice.find_by_no(params[:invoice_no])
    raise ActiveRecord::RecordNotFound unless @inv
    self.count_lines! if request.get?
    update_and_redirect if request.post?
  end

  def add_line
    render(:nothing => true) if params[:nline][:item_no].blank?
    @line = InvoiceItem.new(params[:nline])
    @line_count = 1 + params[:line_count].to_i
    render :layout => false
  end

  def delete_line
    @inv = Invoice.find_by_no(params[:invoice_no])
    raise ActiveRecord::RecordNotFound unless @inv
    @line = @inv.lines.find(params[:line])
    @line.destroy
    self.count_lines!
    @index = params[:index]
  end

  def transfer
    @inv = Invoice.find_by_no(params[:invoice_no])
    raise ActiveRecord::RecordNotFound unless @inv

    @lines = Hash.new
    @inv.lines.each do |line|
      @lines[line.account] ||= 0.to_money
      @lines[line.account] += line.extension_price
    end

    @lines = @lines.to_a.sort_by {|line| line.first.no}
    return unless request.post?

    @inv.post!
    redirect_to :action => :index

    rescue
      logger.warn $!
      flash_failure :now, "#{$!.class.name}: #{$!.message}"
      @inv.reload
  end

  protected
  def update_and_redirect
    self.parse_dates
    @inv.customer = Customer.find_by_abbreviation(params[:inv][:customer])
    params[:inv].delete(:customer)
    params[:inv].delete('customer')

    if params[:line] then
      params[:line].each do |id, values|
        @line = @inv.lines.find(id) rescue @inv.lines.build
        unless @line.update_attributes(values) then
          flash_failure :now, "Erreur de mise à jour ligne #{id}: #{@line.errors.full_messages.join(', ')}"
        end
      end
    end

    if @inv.update_attributes(params[:inv]) then
      if params[:commit] =~ /nouveau/i then
        redirect_to invoice_new_url
      else
        redirect_to invoices_url
      end
    end
  end

  def count_lines!
    return @inv.lines.count if @inv.new_record?
    count = InvoiceItem.connection.select_value("SELECT MAX(id) FROM #{InvoiceItem.table_name} WHERE invoice_id = #{@inv.id}")
    @line_count = count.to_i rescue 0
  end

  def parse_dates
    return unless params[:inv]
    params[:inv][:invoiced_on] = parse_date(params[:inv][:invoiced_on])
  end
end
