require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < Test::Unit::TestCase
  should_have_valid_fixtures
end

class AccountBalanceTest < Test::Unit::TestCase
  def setup
    @account = Account.new
    @account.stubs(:total_dt_volume).returns(145.to_money)
    @account.stubs(:total_ct_volume).returns(33.to_money)
  end

  def test_when_normally_debitor
    @account.account_type = AccountType.new('asset')
    assert_equal (145 - 33).to_money, @account.balance
  end

  def test_when_creditor
    @account.account_type = AccountType.new('liability')
    assert_equal (33 - 145).to_money, @account.balance
  end
end
