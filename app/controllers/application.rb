class ApplicationController < ActionController::Base
  before_filter :load_company

  protected
  def load_company
    @company = Company.find(:first)
  end
end
