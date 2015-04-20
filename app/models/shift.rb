class Shift < ActiveRecord::Base
  attr_accessible :end_at, :name, :start_at, :hotel_src_id, :used
  validates_presence_of :start_at, :end_at
  before_create :hotel_src
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
