class StayList < ActiveRecord::Base
  attr_accessible :room_list_id,:fname,:lname,
                  :abf_rate,:ext_bed_rate,:status,:hotel_src_id
  before_create :hotel_src
  belongs_to :room_list
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
