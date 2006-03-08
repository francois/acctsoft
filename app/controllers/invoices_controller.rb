class InvoicesController < ApplicationController
  before_filter :parse_dates, :only => [:new, :edit]

  def index
    @invoices = Invoice.find(:all, :order => 'no DESC')
  end

  def new
    @inv = Invoice.new
    update_and_redirect('new') if request.post?
  end

  def edit
    @inv = Invoice.find_by_no(params[:invoice])
    raise ActiveRecord::RecordNotFound unless @inv
    update_and_redirect('edit') if request.post?
  end

  def auto_complete_for_invoice_customer
    @customers = Customer.find(:all, :limit => 20, :order => 'name',
        :conditions => ['abbreviation LIKE ?', "%#{params[:invoice][:customer]}%"])
    render :layout => false
  end

  def add_line
    @line = InvoiceItem.new(params[:nline])
    @line_count = 1 + params[:line_count].to_i
  end

  def transfer
    @inv = Invoice.find_by_no(params[:invoice])
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
  def update_and_redirect(form)
    @inv.customer = Customer.find_by_abbreviation(params[:inv][:customer])
    params[:inv].delete(:customer)
    params[:inv].delete('customer')

    new_record = @inv.new_record?

    if @inv.update_attributes(params[:inv]) then
      params[:line].each do |id, values|
        @line = new_record ? @inv.lines.build : @inv.lines.find(id)
        unless @line.update_attributes(values) then
          flash_failure :now, "Erreur de mise à jour ligne #{id}: #{@line.errors.full_messages.join(', ')}"
        end
      end

      if params[:commit] =~ /nouveau/i then
        redirect_to :action => :new
      else
        redirect_to :action => :index
      end
    else
      render :action => form
    end
  end

  def parse_dates
    return unless params[:inv]
    params[:inv][:invoiced_on] = parse_date(params[:inv][:invoiced_on])
  end
end
