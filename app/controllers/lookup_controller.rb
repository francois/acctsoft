class LookupController < ApplicationController
  def auto_complete_for_account
    @accounts = Account.find(:all, :order => 'no', :limit => 20,
        :conditions => ['no LIKE :no OR name LIKE :no OR description LIKE :no',
            {:no => "#{params[:account]}%"}])
    render :layout => false
  end

  def auto_complete_for_customer
    @customers = Customer.find(:all, :limit => 20, :order => 'name',
        :conditions => ['abbreviation LIKE ?', "#{params[:customer]}%"])
    render :layout => false
  end

  def auto_complete_for_invoice
    @invoices = unless params[:customer].blank? then
                  customer = Customer.find_by_abbreviation(params[:customer])
                  customer.invoices.find(:all, :order => 'no DESC',
                      :conditions => ['no LIKE ?', "#{params[:invoice]}%"])
                else
                  Invoice.find(:all, :order => 'no DESC',
                      :conditions => ['no LIKE ?', "#{params[:invoice]}%"])
                end
    render :layout => false
  end
end
