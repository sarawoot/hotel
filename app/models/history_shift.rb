class HistoryShift < ActiveRecord::Base
  attr_accessible :login_at, :logout_at, :shift_id, :user_id, :hotel_src_id
  before_create :hotel_src
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
