class RoomList < ActiveRecord::Base
  default_scope { order("room_lists.id") }
  attr_accessible :arvl_by, :arvl_at, :dpt_by, :dpt_at, :hotel_src_id,
                  :input_type_id, :room_id, :room_rate, :status, :stay_lists_attributes,
                  :room_type_id, :expenses_attributes
  belongs_to :input_type
  has_one :contact, :through => :input_type
  belongs_to :room
  has_one :room_type, :through => :room
  has_many :log_move_rooms, :dependent => :destroy
  
  has_many :expenses, :dependent => :destroy
  accepts_nested_attributes_for :expenses, reject_if: proc { |a| a['product_id'].blank? }, allow_destroy: true
  
  has_many :stay_lists, :dependent => :destroy
  accepts_nested_attributes_for :stay_lists, :allow_destroy => true
  before_create :hotel_src
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
  

end
