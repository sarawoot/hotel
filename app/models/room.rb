class Room < ActiveRecord::Base
  attr_accessible :floor_id, :room_no, :status, :used, :seq,
                  :hotel_src_id, :room_type_id, :stay_lists_attributes

  belongs_to :floor
  belongs_to :room_type
  
  has_many :room_lists, :dependent => :destroy
  accepts_nested_attributes_for :room_lists
  
  has_many :stay_lists, :through => :room_lists
  accepts_nested_attributes_for :stay_lists, allow_destroy: true
  
  
  

  before_create :hotel_src
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
