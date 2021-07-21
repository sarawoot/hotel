class CreateTrialBalances < ActiveRecord::Migration
  def change
    create_table :trial_balances do |t|
      t.integer :seq
      t.string :product_name
      t.integer :products_id
      t.decimal :debit
      t.decimal :credit
      t.string :username

      t.timestamps
    end
  end
end
