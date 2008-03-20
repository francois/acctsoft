class LookupController < ApplicationController
  def auto_complete_for_account
    @accounts = Account.find(:all, :order => 'no', :limit => 20,
        :conditions => ['no LIKE :no OR name LIKE :no OR description LIKE :no',
            {:no => "#{params[:q]}%"}])
    respond_to do |format|
      format.html { render :layout => false }
      format.text { render :text => @accounts.map {|a| [a.no, a.name].join(" ")}.join("\n") }
    end
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
