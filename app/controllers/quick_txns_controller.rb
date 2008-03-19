class QuickTxnsController < ApplicationController
  def create
    @quicktxn = QuickTxn.new(params[:quicktxn])
    if @quicktxn.save then
      flash[:notice] = "Débité #{@quicktxn.amount} de #{@quicktxn.debit_account} et crédité #{@quicktxn.credit_account}."
      redirect_to params[:rt] || summary_path
    else
      render :template => "transactions/new"
    end
  end
end
