ActionController::Routing::Routes.draw do |map|
  NumericRegexp = /\d+/.freeze

  map.summary '/', :controller => 'home', :action => 'index'

  map.delete_transaction_line '/transactions/:txn_id/delete/:line', :controller => 'transactions', :action => 'delete_line', :txn_id => NumericRegexp, :line => NumericRegexp
  map.transaction_edit '/transactions/:txn_id', :controller => 'transactions', :action => 'edit', :txn_id => NumericRegexp
  map.transaction_new '/transactions/nouvelle', :controller => 'transactions', :action => 'new'
  map.transactions '/transactions', :controller => 'transactions', :action => 'index'

  map.accounts '/comptes', :controller => 'accounts', :action => 'index'
  map.account_edit '/comptes/:account_no', :controller => 'accounts', :action => 'edit', :account_no => NumericRegexp
  map.account_new '/comptes/nouveau', :controller => 'accounts', :action => 'new'

  map.customer_edit '/clients/edit/:id', :controller => 'customers', :action => 'edit'
  map.customers '/clients/:action/:id', :controller => 'customers'

  map.with_options(:controller => 'reconciliations') do |m|
    m.reconciliations '/reconciliations', :action => 'index'
    m.reconciliation_new '/reconciliations/new', :action => 'edit'
    m.reconciliation_edit '/reconciliations/:id', :action => 'edit'

    m.reconcile '/reconciliations/:reconciliation_id/reconcile/:id', :action => 'reconcile'
    m.unconcile '/reconciliations/:reconciliation_id/unconcile/:id', :action => 'unconcile'
  end

  map.delete_invoice_line '/factures/:invoice_no/delete/:line', :controller => 'invoices', :action => 'delete_line', :invoice_no => NumericRegexp, :line => NumericRegexp
  map.invoice_post '/factures/transfert/:invoice_no', :controller => 'invoices', :action => 'transfer', :invoice_no => NumericRegexp
  map.invoice_edit '/factures/:invoice_no', :controller => 'invoices', :action => 'edit', :invoice_no => NumericRegexp
  map.invoice_new '/factures/nouvelle', :controller => 'invoices', :action => 'new'
  map.invoices '/factures', :controller => 'invoices', :action => 'index'

  map.delete_payment_line '/paiements/:payment_id/delete/:line', :controller => 'payments', :action => 'delete_line', :payment_id => NumericRegexp, :line => NumericRegexp
  map.payment_post '/paiements/transfert/:payment_id', :controller => 'payments', :action => 'transfer', :payment_id => NumericRegexp
  map.payment_edit '/paiements/:payment_id', :controller => 'payments', :action => 'edit', :payment_id => NumericRegexp
  map.payment_new '/paiements/nouveau/:invoice_no', :controller => 'payments', :action => 'new', :invoice_no => nil, :requirements => {:invoice_no => NumericRegexp}
  map.payments '/paiements', :controller => 'payments', :action => 'index'

  map.items '/items/:action/:id', :controller => 'items'

  map.account_lookup '/recherche/compte', :controller => 'lookup', :action => 'auto_complete_for_account'
  map.customer_lookup '/recherche/client', :controller => 'lookup', :action => 'auto_complete_for_customer'
  map.invoice_lookup '/recherche/facture', :controller => 'lookup', :action => 'auto_complete_for_invoice'

  map.reports '/rapports', :controller => 'reports', :action => 'index'

  map.config '/compagnie/comptes', :controller => 'account_configurations', :action => 'index'
  map.config '/compagnie/comptes/:id', :controller => 'account_configurations', :action => 'edit'
  map.config '/compagnie', :controller => 'company', :action => 'edit'

  map.connect ':controller/:action/:id'
end
