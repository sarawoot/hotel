class RateCodeDetail < ActiveRecord::Base
  belongs_to :room_type
  belongs_to :rate_code
  attr_accessible :abf_rate, :ext_bed_rate, :rate_code_id, :room_rate, :room_type_id, :hotel_src_id
  before_create :hotel_src
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
