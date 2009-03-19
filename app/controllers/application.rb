class ApplicationController < ActionController::Base
  before_filter :load_request_url
  before_filter :load_company
  before_filter :transform_parameters
  before_filter :quicktxn
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
    return date unless date =~ /^(?:(\d{4})(\d{2})(\d{2}))|(?:(\d{4}).(\d{1,2}).(\d{1,2}))$/
    y, m, d = $1, $2, $3 unless $1.blank?
    y, m, d = $4, $5, $6 if y.blank?
    logger.debug {"Date.new(#{y.inspect}, #{m.inspect}, #{d.inspect})"}
    Date.new(y.to_i, m.to_i, d.to_i)
  end

  def set_content_type
    return unless response.headers['Content-Type'].blank?
    response.headers['Content-Type'] = 'text/html; charset=UTF-8'
  end

  def quicktxn
    @quicktxn = QuickTxn.new
    @quicktxn.debit_account = Account.find(:first)
    @quicktxn.credit_account = @quicktxn.debit_account
    @quicktxn.amount = Money.zero
  end

  def load_request_url
    @request_url = request.env["HTTP_REQUEST_URI"]
  end
end
