class CreateChecks < ActiveRecord::Migration
  def self.up
    create_table :checks do |t|
      t.column :no, :string, :limit => 12
      t.column :date, :date
      t.column :beneficiary, :string
      t.column :amount_cents, :integer
      t.column :amount_currency, :string, :limit => 8
      t.column :reason, :string
      t.column :txn_id, :integer
      t.column :bank_account_id, :integer
    end
  end

  def self.down
    drop_table :checks
  end
end
