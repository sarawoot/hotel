class Contact < ActiveRecord::Base
  attr_accessible :address, :hotel_src_id, :name, :tel, :cid
  before_create :hotel_src
  has_many :input_types, :dependent => :destroy
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
