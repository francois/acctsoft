require File.dirname(__FILE__) + '/../test_helper'

class MoneyTransferTxnAccountTest < Test::Unit::TestCase
  def setup
    @txn = TxnAccount.new
  end

  def test_normalize_to_credit_when_larger_than_debit
    @txn.amount_dt = Money.new(2500, 'CAD')
    @txn.amount_ct = Money.new(10000, 'CAD')

    @txn.save

    assert_equal Money.new(7500, 'CAD'), @txn.amount_ct
    assert @txn.amount_dt.zero?
  end

  def test_normalize_to_debit_when_larger_than_credit
    @txn.amount_dt = Money.new(10000, 'CAD')
    @txn.amount_ct = Money.new(3000, 'CAD')

    @txn.save

    assert_equal Money.new(7000, 'CAD'), @txn.amount_dt
    assert @txn.amount_ct.zero?
  end
end
