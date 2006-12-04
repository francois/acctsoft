require File.dirname(__FILE__) + '/../test_helper'

class AccountBalanceTest < Test::Unit::TestCase
  def setup
    @account_type = AccountType.new
    @account = Account.new(:account_type => @account_type)
    @account.stubs(:total_dt_volume).returns(145.to_money)
    @account.stubs(:total_ct_volume).returns(33.to_money)
  end

  def test_when_normally_debitor
    @account_type.stubs(:normally_debitor?).returns(true)
    @account_type.stubs(:normally_creditor?).returns(false)
    assert_equal (145 - 33).to_money, @account.balance
  end

  def test_when_normally_creditor
    @account_type.stubs(:normally_debitor?).returns(false)
    @account_type.stubs(:normally_creditor?).returns(true)
    assert_equal (33 - 145).to_money, @account.balance
  end
end
