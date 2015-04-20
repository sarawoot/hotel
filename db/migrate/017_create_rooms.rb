class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.integer :floor_id
      t.string :room_no
      t.string :used, limit: 1, default: '1'
      t.string :status, limit: 1
      t.integer :seq
      t.integer :hotel_src_id
      t.integer :room_type_id
      t.timestamps
    end
  end
end
