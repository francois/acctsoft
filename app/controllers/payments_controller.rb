class PaymentsController < ApplicationController
  before_filter :parse_dates

  def index
    @payments = Payment.find(:all, :order => 'received_on DESC')
  end

  def new
    @payment = Payment.new
    return if params[:invoice].blank?

    @invoice = Invoice.find_by_no(params[:invoice])
    raise ActiveRecord::RecordNotFound, "No invoice #{params[:invoice].inspect}" unless @invoice

    case request.method
    when :get
      @payment.customer = @invoice.customer
      @payment.amount = @invoice.balance
      @payment.invoices.build(:invoice => @invoice, :amount => @payment.amount)

    when :post
      update_and_redirect('new')

    else
      response.headers['Content-Type'] = 'text/plain'
      render :inline => '405 Method Not Allowed',
          :status => '405 Method Not Allowed',
          :layout => false
    end
  end

  def edit
    @payment = Payment.find(params[:id])
    update_and_redirect('edit') if request.post?
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
    @line_count = 1 + params[:line_count].to_i
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
    if params[:line] then
      params[:line].each do |id, values|
        @line = @payment.new_record? ? @payment.invoices.build : @payment.invoices.find(id)
        unless @line.update_attributes(values) then
          flash_failure :now, "Erreur de mise à jour ligne #{id}: #{@line.errors.full_messages.join(', ')}"
        end
      end
    end

    if @payment.update_attributes(params[:payment]) then
      flash_notice 'Le total payé ne correspond pas aux montants enregistrés' \
          unless @payment.can_upload?
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
