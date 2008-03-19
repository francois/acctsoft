class PaymentsController < ApplicationController
  def index
    @payments = Payment.paginate(:all, :order => 'received_on DESC', :page => params[:page])
  end

  def new
    @payment = Payment.new

    case request.method
    when :get
      self.count_lines!
      unless params[:invoice_no].blank? then
        @invoice = Invoice.find_by_no(params[:invoice_no])
        raise ActiveRecord::RecordNotFound, "No invoice #{params[:invoice_no].inspect}" unless @invoice

        @payment.customer = @invoice.customer
        @payment.amount = @invoice.balance
        @payment.invoices.build(:invoice => @invoice, :amount => @payment.amount)
      end

    when :post
      update_and_redirect

    else
      response.headers['Content-Type'] = 'text/plain'
      render :inline => '405 Method Not Allowed',
          :status => '405 Method Not Allowed',
          :layout => false
    end
  end

  def edit
    @payment = Payment.find(params[:payment_id])
    self.count_lines! if request.get?
    update_and_redirect if request.post?
  end

  def add_line
    render(:nothing => true) if params[:nline][:no].blank?
    @line = InvoicePayment.new(params[:nline])
    @line_count = 1 + params[:line_count].to_i
    render :layout => false
  end

  def delete_line
    @payment = Payment.find(params[:payment_id])
    @line = @payment.invoices.find(params[:line])
    @line.destroy
    self.count_lines!
    @index = params[:index]
  end

  def transfer
    @payment = Payment.find(params[:payment_id])
    return unless request.post?

    @payment.post!
    redirect_to :action => :index

    rescue
      flash_failure :now, "#{$!.class.name}: #{$!.message}"
      @payment.reload
  end

  protected
  def update_and_redirect
    params[:payment][:customer] = Customer.find_by_abbreviation(params[:payment][:customer])
    if params[:line] then
      params[:line].each do |id, values|
        @line = @payment.invoices.find(id) rescue @payment.invoices.build
        unless @line.update_attributes(values) then
          flash_failure :now, "Erreur de mise à jour ligne #{id}: #{@line.errors.full_messages.join(', ')}"
        end
      end
    end

    if @payment.update_attributes(params[:payment]) then
      flash_notice 'Le total payé ne correspond pas aux montants enregistrés' \
          unless @payment.balanced?
      if params[:commit] =~ /nouveau/i then
        redirect_to payment_new_url
      else
        redirect_to payments_url
      end
    end
  end

  def count_lines!
    return @payment.invoices.count if @payment.new_record?
    count = InvoicePayment.connection.select_value("SELECT MAX(id) FROM #{InvoicePayment.table_name} WHERE payment_id = #{@payment.id}")
    @line_count = count.to_i rescue 0
  end
end
