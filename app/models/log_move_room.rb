class LogMoveRoom < ActiveRecord::Base
  attr_accessible :input_type_id,:room_list_id,:room_old_id,:room_new_id,:user_id,:remark
  belongs_to :input_type
  belongs_to :room_list
  belongs_to :user
end
