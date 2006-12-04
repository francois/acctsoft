require File.dirname(__FILE__) + '/../test_helper'

class DebitCreditNormalizerTest < Test::Unit::TestCase
  def setup
    @normalizer = DebitCreditNormalizer.new
    @record = mock()
  end

  def test_normalizes_debit_when_credit_smaller
    @record.stubs(:amount_dt).returns(100.to_money)
    @record.stubs(:amount_ct).returns(50.to_money)
    @record.expects(:amount_dt=).with(50.to_money)
    @record.expects(:amount_ct=).with(Money.empty)
    @normalizer.before_validation(@record)
  end

  def test_normalizes_credit_when_debit_smaller
    @record.stubs(:amount_dt).returns(50.to_money)
    @record.stubs(:amount_ct).returns(100.to_money)
    @record.expects(:amount_dt=).with(Money.empty)
    @record.expects(:amount_ct=).with(50.to_money)
    @normalizer.before_validation(@record)
  end

  def test_does_not_touch_credit_if_debit_zero
    @record.stubs(:amount_dt).returns(Money.empty)
    @record.stubs(:amount_ct).returns(5.to_money)
    @normalizer.before_validation(@record)
  end

  def test_does_not_touch_debit_if_credit_zero
    @record.stubs(:amount_dt).returns(5.to_money)
    @record.stubs(:amount_ct).returns(Money.empty)
    @normalizer.before_validation(@record)
  end
end
