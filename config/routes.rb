ActionController::Routing::Routes.draw do |map|
  NumericRegexp = /\A\d+\Z/.freeze

  map.summary '/', :controller => 'home', :action => 'index'

  map.delete_transaction_line '/transactions/:transaction/delete/:line', :controller => 'transactions', :action => 'delete_line', :transaction => NumericRegexp, :line => NumericRegexp
  map.transaction_edit '/transactions/:txn', :controller => 'transactions', :action => 'edit', :txn => NumericRegexp
  map.transaction_new '/transactions/nouvelle', :controller => 'transactions', :action => 'new'
  map.transactions '/transactions', :controller => 'transactions', :action => 'index'

  map.accounts '/comptes', :controller => 'accounts', :action => 'index'
  map.account_edit '/comptes/:account', :controller => 'accounts', :action => 'edit', :account => NumericRegexp
  map.account_new '/comptes/nouveau', :controller => 'accounts', :action => 'new'

  map.customers '/clients/:action/:id', :controller => 'customers'
  map.customer_edit '/clients/edit/:id', :controller => 'customers', :action => 'edit'

  map.delete_invoice_line '/factures/:invoice/delete/:line', :controller => 'invoices', :action => 'delete_line', :invoice => NumericRegexp, :line => NumericRegexp
  map.invoice_post '/factures/transfert/:invoice', :controller => 'invoices', :action => 'transfer', :invoice => NumericRegexp
  map.invoice_edit '/factures/:invoice', :controller => 'invoices', :action => 'edit', :invoice => NumericRegexp
  map.invoice_new '/factures/nouvelle', :controller => 'invoices', :action => 'new'
  map.invoices '/factures', :controller => 'invoices', :action => 'index'

  map.delete_payment_line '/paiements/:payment/delete/:line', :controller => 'payments', :action => 'delete_line', :payment => NumericRegexp, :line => NumericRegexp
  map.payment_post '/paiements/transfert/:id', :controller => 'payments', :action => 'transfer'
  map.payment_edit '/paiements/:payment', :controller => 'payments', :action => 'edit', :payment => NumericRegexp
  map.payment_new '/paiements/nouveau/:invoice', :controller => 'payments', :action => 'new', :invoice => nil, :requirements => {:invoice => NumericRegexp}
  map.payments '/paiements', :controller => 'payments', :action => 'index'

  map.items '/items/:action/:id', :controller => 'items'

  map.account_lookup '/transactions/auto_complete_for_account_no', :controller => 'transactions', :action => 'auto_complete_for_account_no'
  map.customer_lookup '/invoices/auto_complete_for_invoice_customer', :controller => 'invoices', :action => 'auto_complete_for_invoice_customer'
  map.invoice_lookup '/paiements/auto_complete_for_invoice_no', :controller => 'payments', :action => 'auto_complete_for_invoice_no'

  map.reports '/rapports', :controller => 'reports', :action => 'index'

  map.config '/compagnie/comptes', :controller => 'account_configurations', :action => 'index'
  map.config '/compagnie/comptes/:id', :controller => 'account_configurations', :action => 'edit'
  map.config '/compagnie', :controller => 'company', :action => 'edit'

  map.connect ':controller/:action/:id'
end
