require File.dirname(__FILE__) + '/../test_helper'

class ReconciliationDestructionTest < Test::Unit::TestCase
  fixtures :accounts, :companies, :txns, :txn_accounts

  def setup
    @cash = accounts(:cash)
    @sales = accounts(:sales)
    
    @txn = Txn.create!(:description => 'abc', :posted_on => Date.today)
    @line = @txn.lines.build(:account => @cash, :amount_dt => 100.to_money)
    @txn.lines.build(:account => @sales, :amount_ct => 100.to_money)
    @txn.save!
    
    @reconciliation = Reconciliation.create!(:account => @cash,
        :statement_on => Date.today, :reconciled_at => Time.now)
    @line.reconcile!(@reconciliation)
    
    @reconciliation.reload
    assert_equal 1, @reconciliation.txn_accounts.count
    @reconciliation.destroy
    
    @line.reload
  end

  def test_nullifies_associated_txn_accounts
    assert_nil @line.reconciliation
  end

  def test_reconciliation_record_destroyed
    assert_raises(ActiveRecord::RecordNotFound) do
      Reconciliation.find(@reconciliation.id)
    end
  end

  def test_done_when_totals_match_target_amounts
    Reconciliation.
  end
end
