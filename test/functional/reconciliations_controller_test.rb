require File.dirname(__FILE__) + '/../test_helper'
require 'reconciliations_controller'

# Re-raise errors caught by the controller.
class ReconciliationsController; def rescue_action(e) raise e end; end

class ReconciliationsControllerTest < Test::Unit::TestCase
  fixtures :accounts, :companies, :txns, :txn_accounts

  def setup
    @controller = ReconciliationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @cash = accounts(:cash)
    @sales = accounts(:sales)
    
    @txn = Txn.create!(:description => 'abc', :posted_on => Date.today)
    @line = @txn.lines.build(:account => @cash, :amount_dt => 100.to_money)
    @txn.lines.build(:account => @sales, :amount_ct => 100.to_money)
    @txn.save!
    
    @reconciliation = Reconciliation.create!(:account => @cash,
        :statement_on => Date.today, :reconciled_at => Time.now)
    @line.reconcile!(@reconciliation)
  end

  def test_destroy_nullifies_associations
    post :edit, :id => @reconciliation.id, 
        :destroy => 'Detruire', :reconciliation => {:statement_on => Date.today.to_s(:db)}
    assert_nil @line.reload.reconciliation
  end

  def test_destroy_destroys_reconciliation
    post :edit, :id => @reconciliation.id, 
        :destroy => 'Detruire', :reconciliation => {:statement_on => Date.today.to_s(:db)}
    assert_raises(ActiveRecord::RecordNotFound) {@reconciliation.reload}
  end

  def test_edit_form_posts_to_existing_id
    get :edit, :id => @reconciliation.id
    assert_select "form[action=?]", reconciliation_edit_url(@reconciliation)
  end

  def test_new_form_posts_to_new
    get :edit
    assert_select "form[action=?]", reconciliation_new_url
  end
end
