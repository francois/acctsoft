class HomeController < ApplicationController
  def index
    @transactions = Txn.find(:all, :order => 'posted_on DESC, id DESC', :limit => 20)
  end
end
