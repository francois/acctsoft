require File.dirname(__FILE__) + '/../test_helper'

class MoneyTest < Test::Unit::TestCase
  def test_convert_integer_to_money
    assert_equal 9, 9.to_money.cents
  end

  def test_convert_float_to_money
    assert_equal (9.41 * 100).to_i, 9.41.to_money.cents
  end

  def test_ceil_when_convert_to_money
    assert_equal (13.27 * 100).to_i, 13.261.to_money.cents
  end

  def test_copies_stringified_currency_when_convert_to_money
    assert_equal 'IUD', 1.to_money("IUD").currency
  end

  def test_zero_cents_is_zero
    assert 0.to_money.zero?
  end

  def test_substract_from_zero
    assert_equal -12.to_money, Money.empty - (12.to_money)
  end

  def test_substract_from_zero2
    assert_equal -12.to_money, Money.zero - (12.to_money)
  end

  def test_negative_money
    assert_equal Money.new(-1232, "CAD"), "-12.32 cad".to_money
  end

  def test_add_negative_amount
    assert_equal -12.to_money, 1.to_money + -13.to_money
    assert_equal -1200.to_money, Money.zero + ('-12'.to_money)
  end

  def test_convert_string_to_money
    assert_equal Money.new(1211, "CAD"), "12.11".to_money
  end

  def test_convert_string_to_money_with_comma
    assert_equal Money.new(1211, "CAD"), "12,11".to_money
  end
end
