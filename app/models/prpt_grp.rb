class PrptGrp < ActiveRecord::Base
  attr_accessible :name, :used, :hotel_src_id
  before_create :hotel_src
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
