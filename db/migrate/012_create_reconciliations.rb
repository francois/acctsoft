class CreateReconciliations < ActiveRecord::Migration
  def self.up
    create_table :reconciliations do |t|
      t.column :description, :string
      t.column :account_id, :integer, :null => false
      t.column :statement_on, :date, :null => false
      t.column :reconciled_at, :datetime, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :reconciliations
  end
end
