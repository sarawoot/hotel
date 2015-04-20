class CreateHistoryShifts < ActiveRecord::Migration
  def change
    create_table :history_shifts do |t|
      t.integer :user_id
      t.integer :shift_id
      t.datetime :login_at
      t.datetime :logout_at
      t.integer :hotel_src_id
      t.timestamps
    end
  end
end
