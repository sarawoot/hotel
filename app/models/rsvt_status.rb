class RsvtStatus < ActiveRecord::Base
  attr_accessible :name, :used, :hotel_src_id, :status
  has_many :book_idvs, :dependent => :destroy
  
  before_create :hotel_src
  
  
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
