class Product < ActiveRecord::Base
  
  attr_accessible :category, :hotel_src_id, :name, :used, :price, :config, :product_place_id
  validates_uniqueness_of :name
  has_many :expenses, :dependent => :destroy
  belongs_to :product_place
  before_create :hotel_src
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
  
  def product_name
    product = []
    place = begin product_place.name rescue "" end
    #config_ = ApplicationController.helpers.product_config(config)
    product.push(place) if place != ""
    #product.push(config_) if config_ != ""
    product.push(name)
    product.join("/")
  end
  
  
  
end
