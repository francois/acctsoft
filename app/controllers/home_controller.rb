class HomeController < ApplicationController
  def index
    @transactions = Txn.paginate(:all, :order => 'posted_on DESC, id DESC', :page => params[:page])
  end
end
