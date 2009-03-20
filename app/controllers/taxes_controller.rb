class TaxesController < ApplicationController
  def show
    @income_accounts        = Account.find_all_by_account_type(AccountType::INCOME)

    @payable_gst_account    = AccountConfiguration.get("TPS à payer")
    @receivable_gst_account = AccountConfiguration.get("TPS à recevoir")
    @payable_pst_account    = AccountConfiguration.get("TVQ à payer")
    @receivable_pst_account = AccountConfiguration.get("TVQ à recevoir")

    @quarters = []
    4.times do |index|
      start   = Date.today.at_beginning_of_quarter << (3*index)
      quarter = ((start.month - 1) / 3) + 1
      @quarters << ["Q#{quarter} #{start.year}", index]
    end
    @quarter = params[:q].to_i || @quarters.first.last

    @qend   = (Date.today.at_beginning_of_quarter << (3 * (@quarter - 1))) - 1
    @qstart = @qend.at_beginning_of_quarter

    # Income is normally creditor, but if we reimburse a customer, we need to remove that portion from our revenue
    @income_amount         = @income_accounts.map {|a| a.total_ct_volume(@qend)}.sum(Money.zero) - @income_accounts.map {|a| a.total_ct_volume(@qstart)}.sum(Money.zero)
    @income_amount        -= @income_accounts.map {|a| a.total_dt_volume(@qend)}.sum(Money.zero) - @income_accounts.map {|a| a.total_dt_volume(@qstart)}.sum(Money.zero)

    @payable_gst_amount    = @payable_gst_account.total_ct_volume(@qend)    - @payable_gst_account.total_ct_volume(@qstart)
    @receivable_gst_amount = @receivable_gst_account.total_ct_volume(@qend) - @receivable_gst_account.total_ct_volume(@qstart)
    @payable_pst_amount    = @payable_pst_account.total_ct_volume(@qend)    - @payable_pst_account.total_ct_volume(@qstart)
    @receivable_pst_amount = @receivable_pst_account.total_ct_volume(@qend) - @receivable_pst_account.total_ct_volume(@qstart)

    @gst_amount            = @payable_gst_amount - @receivable_gst_amount
    @pst_amount            = @payable_pst_amount - @receivable_pst_amount

    @whole_amount          = @gst_amount + @pst_amount
  end
end
