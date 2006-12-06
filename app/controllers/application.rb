class ApplicationController < ActionController::Base
  before_filter :load_company
  before_filter :pagination_handler, :only => [:index]
  before_filter :transform_parameters
  after_filter :set_content_type

  protected
  def load_company
    @company = Company.find(:first)
  end

  def transform_parameters(root=params)
    root.each_pair do |key, value|
      root[key] = parse_date(value) if key =~ /_on$/
      root[key] = root[key].to_money if key =~ /amount/
      transform_parameters(value) if value.kind_of?(Hash)
    end
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
