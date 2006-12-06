require File.dirname(__FILE__) + '/../test_helper'

class CheckValidityTest < Test::Unit::TestCase
  fixtures :accounts

  def setup
    @bank_account = accounts(:cash)
    @supplier_account = accounts(:supplier)
    @check = Check.new(:amount => 100.to_money, :reason => 'payment',
        :no => '1031', :written_on => Date.new(2006, 10, 25),
        :beneficiary => 'supplier', :bank_account => @bank_account)
    @check.distributions.build(:amount_dt => @check.amount, :account => @supplier_account)
    @check.valid?
  end

  def test_valid_as_entered
    assert @check.errors.empty?, @check.errors.full_messages
  end

  def test_invalid_if_missing_no
    @check.no = nil
    assert_check_invalid
  end

  def test_invalid_if_missing_date
    @check.written_on = nil
    assert_check_invalid
  end

  def test_invalid_if_missing_reason
    @check.reason = nil
    assert_check_invalid
  end

  def test_invalid_if_missing_beneficiary
    @check.beneficiary = nil
    assert_check_invalid
  end

  def test_invalid_if_missing_bank_account
    @check.bank_account = nil
    assert_check_invalid
  end

  def test_generates_missing_distribution_on_save
    @check.save!
    assert_not_nil @check.distributions(true).find(:first, :conditions => ['account_id = ?', @bank_account.id])
  end

  def test_updates_bank_amount_on_save
    @check.save!
    @check.reload
    @check.amount = 125.to_money
    @check.distributions.find(:first, :conditions => ['account_id = ?', @supplier_account.id]).update_attribute(:amount_dt, 125.to_money)
    @check.save!

    assert_equal 125.to_money, @check.distributions(true).find(:first, :conditions => ['account_id = ?', @bank_account.id]).amount_ct
  end

  private
  def assert_check_invalid
    assert !@check.valid?, "Expected @check to be invalid, got: #{@check.errors.full_messages.join(', ')}"
  end
end

class CheckTransferTest < Test::Unit::TestCase
  fixtures :accounts

  def setup
    @bank_account = accounts(:cash)
    @supplier_account = accounts(:supplier)
    @check = Check.new(:amount => 111.to_money, :reason => 'payment',
        :no => '1032', :written_on => Date.new(2006, 10, 25),
        :beneficiary => 'supplier', :bank_account => @bank_account)
    @check.distributions.build(:amount_dt => @check.amount, :account => @supplier_account)
    @check.save!

    @original_bank_balance = @bank_account.balance(true)
    @original_supplier_balance = @supplier_account.balance(true)

    @check.transfer!
  end

  def test_bank_account_balance_credited
    assert_equal 111.to_money, @bank_account.total_ct_volume(1.day.from_now, true)
    assert_equal Money.zero, @bank_account.total_dt_volume(1.day.from_now, true)
    assert_equal @original_bank_balance - 111.to_money, @bank_account.balance(true)
  end

  def test_supplier_account_balance_debited
    assert_equal 111.to_money, @supplier_account.total_dt_volume(1.day.from_now, true)
    assert_equal Money.zero, @supplier_account.total_ct_volume(1.day.from_now, true)
    assert_equal @original_supplier_balance - 111.to_money,
        @supplier_account.balance(true)
  end
end

class UnbalancedCheckTransferTest < Test::Unit::TestCase
  fixtures :accounts

  def setup
    @bank_account = accounts(:cash)
    @supplier_account = accounts(:supplier)
    @check = Check.new(:amount => 122.to_money, :reason => 'payment',
        :no => '1033', :written_on => Date.new(2006, 10, 25),
        :beneficiary => 'supplier', :bank_account => @bank_account)
    @check.distributions.build(:amount_dt => @check.amount * 2, :account => @supplier_account)
    @check.save!
  end

  def test_rejects_transfer_request
    assert_raises(UnbalancedCheckException) { @check.transfer! }
  end
end
