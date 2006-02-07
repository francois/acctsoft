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
end
