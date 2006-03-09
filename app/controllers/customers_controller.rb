class CustomersController < ApplicationController
  def index
    @customers = Customer.find(:all, :order => 'name')
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new
    update_and_redirect('new')
  end

  def edit
    @customer = Customer.find(params[:id])
  end

  def update
    @customer = Customer.find(params[:id])
    update_and_redirect('edit')
  end

  protected
  def update_and_redirect(form)
    if @customer.update_attributes(params[:customer])
      if params[:commit] =~ /nouveau/i then
        redirect_to :action => :new
      else
        redirect_to :action => :index
      end
    else
      render :action => form
    end
  end
end
