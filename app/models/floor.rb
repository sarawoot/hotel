class Floor < ActiveRecord::Base
  has_many :rooms, :dependent => :destroy
  attr_accessible :name, :seq, :used, :hotel_src_id
  before_create :hotel_src
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
