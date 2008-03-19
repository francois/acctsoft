require "money"
require "xl_suite/acts_as_money"
require "xl_suite/money_extensions"
require "xl_suite/money_extensions/integer"
require "xl_suite/money_extensions/float"
require "xl_suite/money_extensions/string"

ActiveRecord::Base.send :extend, XlSuite::ActsAsMoney
Money.send :include, XlSuite::MoneyExtensions
Integer.send :include, XlSuite::MoneyExtensions::Integer
Float.send :include, XlSuite::MoneyExtensions::Float
String.send :include, XlSuite::MoneyExtensions::String
