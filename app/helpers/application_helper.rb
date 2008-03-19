module ApplicationHelper
  def show_flash(key)
    return nil if flash[key].blank?
    content_tag(:div, content_tag(:div, textilize(flash[key]), :class => "notice"), :id => "messages")
  end

  def label(object, field, label=nil)
    %Q(<label for="#{object}_#{field}">#{label ? label : field.to_s.humanize}</label>)
  end

  def text_field(*args)
    if args.last.kind_of?(Hash) then
      args.last[:autocomplete] = 'off' unless args.last.has_key?(:autocomplete)
    else
      args << {:autocomplete => 'off'}
    end

    super(*args)
  end

  def text_field_tag(*args)
    if args.last.kind_of?(Hash) then
      args.last[:autocomplete] = 'off' unless args.last.has_key?(:autocomplete)
    else
      args << {:autocomplete => 'off'}
    end

    super(*args)
  end

  def format_date(date, blank=nil)
    return blank if date.blank?
    date.to_time.strftime('%Y-%m-%d')
  end

  def format_money(amount, blank='', zero=:format)
    return blank if amount.blank?
    cents = amount.respond_to?(:cents) ? amount.cents : amount
    number_to_currency(amount.cents / 100.0, :unit => '', :separator => ',', :delimiter => '&nbsp;')
  end

  def link_to_account(account, options={})
    options = {:text => :full}.merge(options)
    text =  case options[:text]
            when :full
              "#{account.no} #{h(account.name)}"
            when :no
              account.no
            when :name
              h(account.name)
            else
              raise ArgumentError, "Unknown :text option: #{options[:text].inspect}"
            end

    link_to(text, account_edit_url(:account_no => account))
  end

  def link_to_txn(transaction)
    link_to(format_date(transaction.posted_on), transaction_edit_url(:txn_id => transaction))
  end
end
