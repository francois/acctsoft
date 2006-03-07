ActionController::Routing::Routes.draw do |map|
  map.summary '/', :controller => 'home', :action => 'index'

  map.transactions '/transactions', :controller => 'transactions', :action => 'index'
  map.transaction_edit '/transactions/:id', :controller => 'transactions', :action => 'edit', :id => /^\d+$/
  map.transaction_new '/transactions/nouvelle', :controller => 'transactions', :action => 'new'

  map.accounts '/comptes', :controller => 'accounts', :action => 'index'
  map.account_edit '/comptes/:account', :controller => 'accounts', :action => 'edit', :account => /^\d+$/
  map.account_new '/comptes/nouveau', :controller => 'accounts', :action => 'new'

  map.customers '/clients/:action/:id', :controller => 'customers'
  map.customer_edit '/clients/edit/:id', :controller => 'customers', :action => 'edit'
  map.invoices '/factures/:action/:no', :controller => 'invoices', :no => nil, :requirements => {:no => /\A\d+\Z/}
  map.invoice_edit '/factures/edit/:no', :controller => 'invoices', :action => 'edit', :no => nil, :requirements => {:no => /\A\d+\Z/}
  map.payments '/paiements/:action/:id', :controller => 'payments'
  map.payment_transfer '/paiements/transfert/:id', :controller => 'payments', :action => 'transfer'
  map.items '/items/:action/:id', :controller => 'items'

  map.account_lookup '/transactions/auto_complete_for_account_no', :controller => 'transactions', :action => 'auto_complete_for_account_no'
  map.customer_lookup '/invoices/auto_complete_for_invoice_customer', :controller => 'invoices', :action => 'auto_complete_for_invoice_customer'

  map.reports '/rapports', :controller => 'reports', :action => 'index'

  map.config '/compagnie', :controller => 'company', :action => 'edit'

  map.connect ':controller/:action/:id'
end
