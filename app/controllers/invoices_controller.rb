class InvoicesController < ApplicationController
  before_filter :parse_dates

  def index
    @invoices = Invoice.find(:all, :order => 'no')
  end

  def new
    @invoice = Invoice.new
  end

  def create
    @invoice = Invoice.new
    update_and_redirect('new')
  end

  def edit
    @invoice = Invoice.find_by_no(params[:no])
    raise ActiveRecord::RecordNotFound unless @invoice
  end

  def update
    @invoice = Invoice.find_by_no(params[:no])
    raise ActiveRecord::RecordNotFound unless @invoice
    update_and_redirect('edit')
  end

  def auto_complete_for_invoice_customer
    @customers = Customer.find(:all, :limit => 20, :order => 'name',
        :conditions => ['abbreviation LIKE ?', "%#{params[:invoice][:customer]}%"])
    render :layout => false
  end

  def add_line
    @line = InvoiceItem.new(params[:nline])
    @invoice_line_count = 1 + params[:inv][:line_count].to_i
  end

  protected
  def update_and_redirect(form)
    @invoice.customer = Customer.find_by_abbreviation(params[:invoice][:customer])
    params[:invoice].delete(:customer)
    params[:invoice].delete('customer')

    new_record = @invoice.new_record?

    if @invoice.update_attributes(params[:invoice]) then
      params[:line].each do |id, values|
        @line = new_record ? @invoice.lines.build : @invoice.lines.find(id)
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
    return unless params[:invoice]
    params[:invoice][:invoiced_on] = parse_date(params[:invoice][:invoiced_on])
  end
end
