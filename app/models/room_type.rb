class RoomType < ActiveRecord::Base
  has_many :rate_code_details, :dependent => :destroy
  has_many :rooms, :dependent => :destroy
  has_many :room_lists, :dependent => :destroy
  attr_accessible :name, :used, :short_name, :hotel_src_id
  before_create :hotel_src
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
