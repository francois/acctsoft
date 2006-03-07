require File.dirname(__FILE__) + '/../test_helper'

class CustomerTest < Test::Unit::TestCase
  fixtures :customers

  def test_address_storage
    customer = Customer.new(
        :address_line1 => '2050 rue Bureau',
        :address_line2 => 'Bureau 201',
        :address_line3 => '',
        :address_city => 'Fleurimont',
        :address_state => 'QC',
        :address_zip => 'J1G 3N4',
        :address_country => 'CA')

    assert_equal '2050 rue Bureau', customer.address.line1
    assert_equal 'Bureau 201', customer.address.line2        
    assert_equal '', customer.address.line3
    assert_equal 'Fleurimont', customer.address.city
    assert_equal 'QC', customer.address.state
    assert_equal 'J1G 3N4', customer.address.zip
    assert_equal 'CA', customer.address.country
  end

  def test_store_pst_string_rate_as_float
    customer = Customer.new(:pst_rate => '7')
    assert_equal 7.0, customer.pst_rate
  end

  def test_store_pst_float_string_rate_as_float
    customer = Customer.new(:pst_rate => '7.3')
    assert_equal 7.3, customer.pst_rate
  end

  def test_store_pst_float_rate_as_float
    customer = Customer.new(:pst_rate => 7.25)
    assert_equal 7.25, customer.pst_rate
  end

  def test_rounds_pst_rate_at_thousands
    customer = Customer.new(:pst_rate => 7.2525)
    assert_equal 7.253, customer.pst_rate
  end
end
