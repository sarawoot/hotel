class CreateLogMoveRooms < ActiveRecord::Migration
  def change
    create_table :log_move_rooms do |t|
      t.integer :input_type_id
      t.integer :room_list_id
      t.integer :room_old_id
      t.integer :room_new_id
      t.integer :user_id
      t.string  :remark

      t.timestamps
    end
  end
end
