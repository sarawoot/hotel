class RateCode < ActiveRecord::Base
  
  attr_accessible :name, :used, :rate_code_details_attributes, :hotel_src_id
  before_create :hotel_src
  validates_uniqueness_of :name
  validates_presence_of :name
  has_many :rate_code_details, :dependent => :destroy
  accepts_nested_attributes_for :rate_code_details,
                                :reject_if => lambda { |a| a[:room_type_id].to_s == "" or a[:room_rate].to_s == "" },
                                :allow_destroy => true
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end                              
                                
end
