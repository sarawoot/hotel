class CreateRoomLists < ActiveRecord::Migration
  def change
    create_table :room_lists do |t|
      t.integer :room_type_id
      t.integer :room_id
      t.decimal :room_rate
      t.datetime :arvl_at
      t.datetime :dpt_at
      t.integer :input_type_id
      t.string :status
      t.integer :arvl_by
      t.integer :dpt_by
      t.integer :hotel_src_id

      t.timestamps
    end
  end
end
