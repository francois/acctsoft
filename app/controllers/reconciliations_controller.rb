class ReconciliationsController < ApplicationController
  def index
    @reconciliations = Reconciliation.paginate(:all, :order => "statement_on DESC", :page => params[:page])
  end

  def edit
    @reconciliation = params[:id] ? Reconciliation.find(params[:id]) : Reconciliation.new
    return render(:action => :form) unless request.post?

    unless params[:destroy].blank? then
      return redirect_to(:action => :index) if @reconciliation.destroy
      flash_failure :now, "Impossible de détruire la conciliation"
      return render(:action => :form)
    end

    @reconciliation.attributes = params[:reconciliation]
    @reconciliation.reconciled_at = Time.now
    if @reconciliation.save then
      return redirect_to(:action => :index) unless @reconciliation.txn_accounts.count.zero?
      return redirect_to(:action => :edit, :id => @reconciliation.id)
    else
      render(:action => :form)
    end
  end

  def reconcile
    @reconciliation = Reconciliation.find(params[:reconciliation_id])
    @txn_account = TxnAccount.find(params[:id])
    @txn_account.reconcile!(@reconciliation)
  end

  def unconcile
    @reconciliation = Reconciliation.find(params[:reconciliation_id])
    @txn_account = @reconciliation.txn_accounts.find(params[:id])
    @txn_account.unconcile!
  end
end
