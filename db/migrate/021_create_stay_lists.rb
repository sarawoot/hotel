class CreateStayLists < ActiveRecord::Migration
  def change
    create_table :stay_lists do |t|
      t.integer :room_list_id
      t.string :fname
      t.string :lname
      t.decimal :abf_rate
      t.decimal :ext_bed_rate
      t.string :status, limit: 1
      t.integer :hotel_src_id
      t.timestamps
    end
  end
end
