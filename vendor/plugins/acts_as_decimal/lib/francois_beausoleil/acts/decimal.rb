# Copyright (c) 2006 François Beausoleil
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module FrancoisBeausoleil #:nodoc:
  module Acts #:nodoc:
    module Decimal #:nodoc:
      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods #:nodoc
        # Marks a set of columns as being stored as fixed decimal widths instead
        # of floating point values.  Very useful for storing percentage values.
        #
        # == Example
        #  class Invoice < ActiveRecord::Base
        #    acts_as_decimal :federal_tax_rate, :provincial_tax_rate,
        #        :rounding => :raise, :decimals => 3
        #  end
        #
        #  invoice = Invoice.new(:federal_tax_rate => 7, :provincial_tax_rate => 7.5)
        #  invoice.provincial_tax_rate #=> 7.5
        #  invoice.attributes[:provincial_tax_rate] #=> 7500
        def acts_as_decimal(*args)
          options = args.pop if args.last.is_a?(Hash)
          options = {:rounding => :round, :decimals => 2}.merge(options)

          args.each do |field|
            define_method(field) do
              ::FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_float(read_attribute(field), options)
            end

            define_method("#{field}=") do |value|
              write_attribute(field, ::FrancoisBeausoleil::Acts::Decimal::DecimalHelper::to_fixed_decimal(value, options))
            end
          end
        end
      end

      # Defines helper methods that convert between fixed decimal width integers
      # and floating point values.
      module DecimalHelper
        # Raised when the fixed decimal width integer has a fractional part.
        class OverflowError < RuntimeError; end

        # Converts a floating point value to a fixed decimal width integer.
        #
        # == Options
        # * <tt>:decimals</tt>: The number of decimal places.  Defaults to 2.
        # * <tt>:rounding</tt>: The method to apply to the result to make it an
        #                       integer.  One of <tt>:ceil</tt>, <tt>:floor</tt>,
        #                       <tt>:round</tt> or <tt>:raise</tt>.  <tt>:raise</tt>
        #                       raises an OverflowException if the value is not
        #                       an integer after the multiplication.
        #
        # == Examples
        #  to_fixed_decimal(1.225) #=> 123
        #  to_fixed_decimal(1.22, :decimals => 1, :rounding => :ceil) #=> 13
        #  to_fixed_decimal(1.1235, :decimals => 3, :rounding => :floor) #=> 123
        #  to_fixed_decimal(1.1235, :decimals => 2, :rounding => :raise) #=> OverflowError
        #  to_fixed_decimal(nil) #=> nil
        def self.to_fixed_decimal(value, options={})
          return nil unless value
          options = {:decimals => 2, :rounding => :round}.merge(options)
          result = (value.to_f * (10**options[:decimals]))
          case options[:rounding]
          when :raise
            raise OverflowError unless result.to_i == result
          else
            result = result.send(options[:rounding])
          end

          result.to_i
        end

        # Converts a fixed decimal width integer to a floating point value.
        #
        # == Options
        # * <tt>:decimals</tt>: The number of decimal places.  Defaults to 2.
        #
        # == Examples
        #  to_float(123, :decimals => 2) #=> 1.23
        #  to_float(123, :decimals => 3) #=> 0.123
        #  to_float(nil, :decimals => 3) #=> nil
        def self.to_float(value, options={})
          return nil unless value
          options = {:decimals => 2}.merge(options)
          value / (10**options[:decimals]).to_f
        end
      end
    end
  end
end
