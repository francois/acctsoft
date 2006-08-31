require 'test/unit'
require 'francois_beausoleil/acts/decimal'

class ConversionTest < Test::Unit::TestCase
  def test_convert_integer_string_to_zero_decimal_integer
    assert_equal 1, FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_fixed_decimal('1', :decimals => 0)
  end

  def test_convert_float_string_to_one_decimal_integer
    assert_equal 12, FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_fixed_decimal('1.2', :decimals => 1)
  end

  def test_convert_and_round
    assert_equal 123, FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_fixed_decimal('1.225', :decimals => 2, :rounding => :round)
  end

  def test_convert_and_floor
    assert_equal 122, FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_fixed_decimal('1.225', :decimals => 2, :rounding => :floor)
  end

  def test_convert_and_ceil
    assert_equal 123, FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_fixed_decimal('1.221', :decimals => 2, :rounding => :ceil)
  end

  def test_convert_float_to_fixed_decimal_integer
    assert_equal 1221, FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_fixed_decimal(1.221, :decimals => 3)
  end

  def test_convert_fixed_width_to_float
    assert_equal 1.2, FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_float(12, :decimals => 1)
  end

  def test_convert_larger_fixed_width_to_float
    assert_equal 2.33, FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_float(233, :decimals => 2)
  end

  def test_convert_nil_to_float_is_nil
    assert_nil FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_float(nil, :decimals => 2)
  end

  def test_convert_nil_to_fixed_decimal_is_nil
    assert_nil FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_fixed_decimal(nil, :decimals => 2)
  end

  def test_raise_overflow_exception_when_ask_for_error
    assert_raises FrancoisBeausoleil::Acts::Decimal::DecimalHelper::OverflowError do
      FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_fixed_decimal(1.25, :decimals => 1, :rounding => :raise)
    end
  end

  def test_no_overflow_exception_when_ok
    assert_nothing_raised do
      FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_fixed_decimal(1.33, :decimals => 2, :rounding => :raise)
    end
  end
end
