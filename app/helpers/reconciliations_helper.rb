module ReconciliationsHelper
  def reconciliation_label_dt(reconciliation)
    if reconciliation.debits_match? then
      "OK"
    else
      format_money((reconciliation.target_amount_dt - reconciliation.amount_dt).abs)
    end
  end

  def reconciliation_label_ct(reconciliation)
    if reconciliation.credits_match? then
      "OK"
    else
      format_money((reconciliation.target_amount_ct - reconciliation.amount_ct).abs)
    end
  end

  def reconciliation_target_amount_dt_class(reconciliation)
    reconciliation.debits_match? ? "ok" : nil
  end

  def reconciliation_target_amount_ct_class(reconciliation)
    reconciliation.credits_match? ? "ok" : nil
  end
end
