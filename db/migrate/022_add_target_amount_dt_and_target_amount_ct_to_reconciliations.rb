class AddTargetAmountDtAndTargetAmountCtToReconciliations < ActiveRecord::Migration
  def self.up
    add_column :reconciliations, :target_amount_dt_cents, :integer
    add_column :reconciliations, :target_amount_dt_currency, :string, :limit => 6
    add_column :reconciliations, :target_amount_ct_cents, :integer
    add_column :reconciliations, :target_amount_ct_currency, :string, :limit => 6
  end

  def self.down
    remove_column :reconciliations, :target_amount_dt_cents
    remove_column :reconciliations, :target_amount_dt_currency
    remove_column :reconciliations, :target_amount_ct_cents
    remove_column :reconciliations, :target_amount_ct_currency
  end
end
