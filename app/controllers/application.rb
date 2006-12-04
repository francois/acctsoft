class ApplicationController < ActionController::Base
  before_filter :load_company
  before_filter :pagination_handler, :only => [:index]
  after_filter :set_content_type

  protected
  def load_company
    @company = Company.find(:first)
  end

  def parse_date(date)
    return date unless date =~ /^(?:(\d{4})(\d{2})(\d{2}))(\d{4}).(\d{1,2}).(\d{1,2})$/
    Date.new($1.to_i, $2.to_i, $3.to_i)
  end

  def pagination_handler
    params[:page] = session[params[:controller]] unless params[:page]
    session[params[:controller]] = params[:page]
  end

  def set_content_type
    return unless response.headers['Content-Type'].blank?
    response.headers['Content-Type'] = 'text/html; charset=UTF-8'
  end
end
