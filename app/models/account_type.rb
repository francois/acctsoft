class AccountType
  attr_accessor :designation

  ASSET = 'asset'.freeze
  LIABILITY = 'liability'.freeze
  EQUITY = 'equity'.freeze
  INCOME = 'income'.freeze
  EXPENSE = 'expense'.freeze

  DEBITORS = [ASSET, EXPENSE].freeze
  CREDITORS = [LIABILITY, INCOME, EQUITY].freeze
  ALL_TYPES = (DEBITORS + CREDITORS).freeze

  def initialize(designation)
    raise ArgumentError, "Unknown designation: #{designation.inspect}" \
        unless ALL_TYPES.include?(designation)
    @designation = designation
  end

  def debitor?
    DEBITORS.include?(self.designation)
  end

  def creditor?
    CREDITORS.include?(self.designation)
  end

  def name
    case @designation
    when ASSET
      'Actif'
    when LIABILITY
      'Passif'
    when EQUITY
      'Avoir'
    when INCOME
      'Revenu'
    when EXPENSE
      'Dépense'
    else
      raise ArgumentError, "Unknown designation: #{@designation.inspect}"
    end
  end

  class << self
    AccountType::ALL_TYPES.each do |type_name|
      $stderr.puts "==> #{type_name}"
      define_method(type_name) do
        AccountType.new(type_name)
      end

      $stderr.puts "==> #{type_name.pluralize}"
      define_method(type_name.pluralize) do
        [AccountType.const_get(type_name.upcase)]
      end
    end
  end

  def self.for_select
    [['Actif', ASSET], ['Passif', LIABILITY], ['Avoir', EQUITY], ['Revenu', INCOME], ['Dépense', EXPENSE]]
  end
end
