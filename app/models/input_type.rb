class InputType < ActiveRecord::Base
  attr_accessible :tel,:nation_id,:agent_id,:gst_type_id, :contact_id,
                  :gst_level_id,:src_gst_id,:prpt_grp_id,:rsvt_type_id,:rsvt_status_id,:adult,
                  :child,:night,:arvl_at,:dpt_at,:input_by,:location,
                  :rate_code_id,:ref,:remark,:hotel_src_id,
                  :room_lists_attributes,:type,:stay_lists_attributes, :stay_status,
                  :expenses_attributes

  before_create :hotel_src
  belongs_to :rsvt_status
  has_many :room_lists, :dependent => :destroy
  has_many :rooms, :through => :room_lists
  has_many :floors, :through => :rooms
  has_many :log_move_rooms, :dependent => :destroy
  
  
  has_many :expenses, :dependent => :destroy
  has_many :folios, :dependent => :destroy
  belongs_to :contact
  accepts_nested_attributes_for :room_lists, allow_destroy: true
  accepts_nested_attributes_for :expenses,
                                :reject_if => lambda { |a| a[:product_id].to_s == "" or
                                                           a[:price].to_s == "" or
                                                           a[:per_unit].to_s == "" or
                                                           a[:vol].to_s == "" },
                                :allow_destroy => true
  
  def hotel_src
    self.hotel_src_id = User.hotel_src
  end
  
  def full_name
    Contact.find(contact_id).name
  rescue
    ""
  end
  
end
