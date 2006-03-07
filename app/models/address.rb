class Address
  attr_accessor :line1, :line2, :line3, :city, :state, :zip, :country

  def initialize(*args)
    @line1, @line2, @line3, @city, @state, @zip, @country = *args
  end
end
