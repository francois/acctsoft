class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.column :name, :string
      t.column :year, :integer
    end

    create_table :account_types do |t|
      t.column :position, :integer
      t.column :name, :string
      t.column :designation, :string
    end

    create_table :accounts do |t|
      t.column :no, :integer
      t.column :name, :string
      t.column :description, :string
      t.column :type_id, :integer
    end

    create_table :txns do |t|
      t.column :posted_on, :date
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :description, :text
    end

    create_table :txn_accounts do |t|
      t.column :position, :integer
      t.column :txn_id, :integer
      t.column :account_id, :integer
      t.column :amount_dt_cents, :integer
      t.column :amount_dt_currency, :string, :limit => 6
      t.column :amount_ct_cents, :integer
      t.column :amount_ct_currency, :string, :limit => 6
    end
  end

  def self.down
    drop_table :txn_accounts
    drop_table :txns
    drop_table :accounts
    drop_table :account_types
    drop_table :companies
  end
end
