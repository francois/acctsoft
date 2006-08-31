module ApplicationHelper
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
end
