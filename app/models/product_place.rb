class ProductPlace < ActiveRecord::Base
  attr_accessible :hotel_src_id, :name, :used
  has_many :products, :dependent => :destroy
  before_create :hotel_src
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
end
