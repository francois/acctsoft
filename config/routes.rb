ActionController::Routing::Routes.draw do |map|
  map.summary '/', :controller => 'home', :action => 'index'

  map.transactions '/transactions', :controller => 'transactions', :action => 'index'
  map.transaction_edit '/transactions/:id', :controller => 'transactions', :action => 'edit', :id => /^\d+$/
  map.transaction_new '/transactions/nouvelle', :controller => 'transactions', :action => 'new'

  map.accounts '/comptes', :controller => 'accounts', :action => 'index'
  map.account_edit '/comptes/:account', :controller => 'accounts', :action => 'edit', :account => /^\d+$/
  map.account_new '/comptes/nouveau', :controller => 'accounts', :action => 'new'

  map.reports '/rapports', :controller => 'reports', :action => 'index'

  map.config '/compagnie', :controller => 'company', :action => 'edit'

  map.connect ':controller/:action/:id'
end
