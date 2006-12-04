class AccountType
  attr_accessor :designation

  DEBITORS = %w(asset expense)
  CREDITORS = %w(liability income equity)

  def initialize(designation)
    raise ArgumentError, "Unknown designation: #{designation.inspect}" unless DEBITORS.include?(designation) || CREDITORS.include?(designation)
    @designation = designation
  end

  def debitor?
    DEBITORS.include?(self.designation)
  end

  def creditor?
    CREDITORS.include?(self.designation)
  end

  def self.for_select
    [%w(Actif asset), %w(Passif liability), %w(Avoir equity), %w(Revenu income), %w(Dépense expense)]
  end
end
