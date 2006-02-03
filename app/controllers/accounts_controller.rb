class AccountsController < ApplicationController
  def index
    @accounts = Account.find(:all, :order => 'no')
  end

  def new
    @account = Account.new
  end

  def create
    self.index
    @account = Account.new
    @success = @account.update_attributes(params[:account])
  end
end
