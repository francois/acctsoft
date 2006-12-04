require File.dirname(__FILE__) + '/../test_helper'

class ValidTransactionTest < Test::Unit::TestCase
  fixtures :accounts, :companies, :account_types, :txns, :txn_accounts

  def setup
    @txn = Txn.new(:description => 'Sale In Progress')
    @txn.lines.build(:amount_dt => 95.to_money(:CAD), :account => accounts(:cash))
    @txn.lines.build(:amount_ct => 60.to_money(:CAD), :account => accounts(:owner))
    @txn.lines.build(:amount_ct => 35.to_money(:CAD), :account => accounts(:sales))
    @txn.save!
  end

  def test_transaction_volume_equals_one_side_of_the_equation
    assert_equal 95.to_money(:CAD), @txn.volume
  end
end

class InvalidTransactionsTest < Test::Unit::TestCase
  fixtures :accounts, :companies, :account_types, :txns, :txn_accounts

  def setup
    @txn = Txn.new(:description => 'Sale In Progress')
    @txn.lines.build(:amount_dt => 200.to_money(:CAD), :account => accounts(:cash))
    @txn.lines.build(:amount_ct => 150.to_money(:CAD), :account => accounts(:owner))
    @txn.lines.build(:amount_ct => 55.to_money(:CAD), :account => accounts(:sales))
    assert !@txn.save, 'transaction is unbalanced -- should not have saved'
  end

  def test_reports_imbalance_on_transaction
    assert_match /not balanced/i, @txn.errors.on_base.inspect
  end
end
