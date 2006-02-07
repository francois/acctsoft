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

  def format_date(date, blank=nil)
    return blank if date.blank?
    date.to_time.strftime('%d/%m/%Y')
  end

  def format_money(amount, blank='', zero=:format)
    return blank if amount.blank?
    case amount
    when Money
      amount.format(:zero => zero, :html => true)
    else
      number_to_currency(amount)
    end
  end
end
