class CreateSummaryTransactions < ActiveRecord::Migration
  def change
    create_table :summary_transactions do |t|
      t.integer :seq
      t.string :username
      t.string :shift_name
      t.string :product_place
      t.decimal :room_list_id
      t.decimal :amount
      t.decimal :payment
      t.decimal :vol

      t.timestamps
    end
  end
end
