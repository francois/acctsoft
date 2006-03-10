class Money
  def ceil
    Money.new(@cents.ceil, self.currency)
  end

  def floor
    Money.new(@cents.floor, self.currency)
  end

  def round
    Money.new(@cents.round, self.currency)
  end

  def abs
    Money.new(@cents.abs, self.currency)
  end
end
