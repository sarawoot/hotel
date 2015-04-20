class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.integer :room_list_id
      t.integer :product_id
      t.decimal :price
      t.decimal :per_unit
      t.integer :user_id
      t.integer :vol
      t.integer :hotel_src_id
      t.integer :input_type_id
      t.integer :folio_id
      t.date    :at_date
      t.string  :ref
      t.integer :shift_id

      t.timestamps
    end
  end
end
