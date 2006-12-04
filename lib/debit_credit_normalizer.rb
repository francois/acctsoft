class DebitCreditNormalizer
  def before_validation(record)
    return if record.amount_dt.zero? or record.amount_ct.zero?
    if record.amount_dt > record.amount_ct then
      record.amount_dt -= record.amount_ct
      record.amount_ct = Money.empty
    else
      record.amount_ct -= record.amount_dt
      record.amount_dt = Money.empty
    end
  end
end
