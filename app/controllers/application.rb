class ApplicationController < ActionController::Base
  before_filter :load_company

  protected
  def load_company
    @company = Company.find(:first)
  end

  def parse_date(date)
    return date unless date =~ /^(?:(\d{4})(\d{2})(\d{2}))(\d{4}).(\d{1,2}).(\d{1,2})$/
    Date.new($1.to_i, $2.to_i, $3.to_i)
  end
end
