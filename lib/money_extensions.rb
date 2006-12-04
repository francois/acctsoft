class Money
  %w(abs floor ceil round -@).each do |sym|
    define_method(sym) do
      self.class.new(self.cents.send(sym), self.currency)
    end
  end

  def zero?
    self.cents.zero?
  end

  def nonzero?
    !self.cents.zero?
  end

  def +@
    self
  end

  def round_to_nearest_dollar
    self.class.new((cents / 100.0).ceil * 100, self.currency)
  end

  def to_f
    self.cents / 100.0
  end

  Penny = '0.01'.to_money.freeze
  Zero = '0.00'.to_money.freeze

  class << self
    def penny; Penny; end
    def zero; Zero; end
  end
end
