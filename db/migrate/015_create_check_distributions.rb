class CreateCheckDistributions < ActiveRecord::Migration
  def self.up
    create_table :check_distributions do |t|
      t.column :check_id, :integer, :default => 0, :null => false
      t.column :position, :integer, :default => 0, :null => false
      t.column :account_id, :integer, :default => 0, :null => false
      t.column :amount_dt_cents, :integer
      t.column :amount_dt_currency, :string, :limit => 6
      t.column :amount_ct_cents, :integer
      t.column :amount_ct_currency, :string, :limit => 6
    end
  end

  def self.down
    drop_table :check_distributions
  end
end
