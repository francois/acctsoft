class PaymentsController < ApplicationController
  before_filter :parse_dates

  def index
    @payments = Payment.find(:all, :order => 'received_on DESC')
  end

  def new
    @payment = Payment.new
  end

  def create
    @payment = Payment.new
    update_and_redirect('new')
  end

  def edit
    @payment = Payment.find(params[:id])
  end

  def update
    @payment = Payment.find(params[:id])
    update_and_redirect('edit')
  end

  def auto_complete_for_invoice_no
    @invoices = unless params[:customer].blank? then
                  customer = Customer.find_by_abbreviation(params[:customer])
                  customer.invoices.find(:all, :order => 'no DESC',
                      :conditions => ['no LIKE ?', "#{params[:invoice][:no]}%"])
                else
                  Invoice.find(:all, :order => 'no DESC',
                      :conditions => ['no LIKE ?', "#{params[:invoice][:no]}%"])
                end
    render :layout => false
  end

  def add_line
    @line = InvoicePayment.new(params[:nline])
    @invoice_line_count = 1 + params[:invoice_line_count].to_i
    render :layout => false
  end

  def transfer
    @payment = Payment.find(params[:id])
    return unless request.post?

    @payment.post!
    redirect_to :action => :index

    rescue
      flash_failure :now, "#{$!.class.name}: #{$!.message}"
      @payment.reload
  end

  protected
  def update_and_redirect(form)
    params[:payment][:customer] = Customer.find_by_abbreviation(params[:payment][:customer])
    new_record = @payment.new_record?
    if @payment.update_attributes(params[:payment]) then
      params[:line].each do |id, values|
        @line = new_record ? @payment.invoices.build : @payment.invoices.find(id)
        unless @line.update_attributes(values) then
          flash_failure :now, "Erreur de mise à jour ligne #{id}: #{@line.errors.full_messages.join(', ')}"
        end
      end

      flash_notice 'Total payé ne correspond pas aux montants enregistrés' unless @payment.can_upload?
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
    return unless params[:payment]
    params[:payment][:paid_on] = parse_date(params[:payment][:paid_on])
    params[:payment][:received_on] = parse_date(params[:payment][:received_on])
  end
end
