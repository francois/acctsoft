class AccountConfigurationsController < ApplicationController
  def index
    @account_configurations = AccountConfiguration.find(:all, :order => 'name')
  end

  def new
    @account_configuration = AccountConfiguration.new
  end

  def create
    @account_configuration = AccountConfiguration.new
    update_and_redirect('new')
  end

  def edit
    @account_configuration = AccountConfiguration.find(params[:id])
  end

  def update
    @account_configuration = AccountConfiguration.find(params[:id])
    update_and_redirect('edit')
  end

  protected
  def update_and_redirect(form)
    if @account_configuration.update_attributes(params[:account_configuration]) then
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
