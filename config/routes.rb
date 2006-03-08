ActionController::Routing::Routes.draw do |map|
  NumericRegexp = /\A\d+\Z/.freeze

  map.summary '/', :controller => 'home', :action => 'index'

  map.transactions '/transactions', :controller => 'transactions', :action => 'index'
  map.transaction_edit '/transactions/:id', :controller => 'transactions', :action => 'edit', :id => NumericRegexp
  map.transaction_new '/transactions/nouvelle', :controller => 'transactions', :action => 'new'

  map.accounts '/comptes', :controller => 'accounts', :action => 'index'
  map.account_edit '/comptes/:account', :controller => 'accounts', :action => 'edit', :account => NumericRegexp
  map.account_new '/comptes/nouveau', :controller => 'accounts', :action => 'new'

  map.customers '/clients/:action/:id', :controller => 'customers'
  map.customer_edit '/clients/edit/:id', :controller => 'customers', :action => 'edit'

  map.invoice_edit '/factures/:invoice', :controller => 'invoices', :action => 'edit', :invoice => NumericRegexp
  map.invoice_post '/factures/transfert/:invoice', :controller => 'invoices', :action => 'transfer', :invoice => NumericRegexp
  map.invoice_new '/factures/nouvelle', :controller => 'invoices', :action => 'new'
  map.invoices '/factures', :controller => 'invoices', :action => 'index'

  map.payments '/paiements/:action/:id', :controller => 'payments'
  map.payment_transfer '/paiements/transfert/:id', :controller => 'payments', :action => 'transfer'

  map.items '/items/:action/:id', :controller => 'items'

  map.account_lookup '/transactions/auto_complete_for_account_no', :controller => 'transactions', :action => 'auto_complete_for_account_no'
  map.customer_lookup '/invoices/auto_complete_for_invoice_customer', :controller => 'invoices', :action => 'auto_complete_for_invoice_customer'

  map.reports '/rapports', :controller => 'reports', :action => 'index'

  map.config '/compagnie/comptes', :controller => 'account_configurations', :action => 'index'
  map.config '/compagnie/comptes/:id', :controller => 'account_configurations', :action => 'edit'
  map.config '/compagnie', :controller => 'company', :action => 'edit'

  map.connect ':controller/:action/:id'
end
