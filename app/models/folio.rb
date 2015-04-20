class Folio < ActiveRecord::Base
  attr_accessible :folio_no, :hotel_src_id, :input_type_id, :remark,
                  :expenses_attributes, :shift_id, :at_date
  belongs_to :input_type
  has_many :expenses, :dependent => :destroy
  
  accepts_nested_attributes_for :expenses, reject_if: proc { |a| a['product_id'].blank? },
                                allow_destroy: true
  
  before_create :hotel_src
  def hotel_src
    sh = get_shift
    self.hotel_src_id = User.hotel_src
    self.folio_no = gen_folio_no
    self.at_date = sh[:at_date]
    self.shift_id = sh[:shift_id]
  end
  
  private
  def gen_folio_no
    # format = "F000001/56"
    date = Time.now
    rs = Folio.select("max(split_part(split_part(folio_no,'F','2'),'/',1)::int) as max_id" )
        .where("split_part(split_part(folio_no,'F','2'),'/',2) = substring((extract(year from now())+543)::varchar from 3 for 2)")
        .first.max_id
    "F#{"%06d" % (rs.to_i + 1)}/#{(date.year+543).to_s[-2..-1]}"
  end
  
  def get_shift
    now = Time.now  
    now = DateTime.new(now.year,now.mon,now.day,now.hour,now.min)  
    duration = [] 
    shift_id = nil
    at_date = nil
    Shift.where(hotel_src_id: User.hotel_src, used: '1' ).each do |rs| 
      start_at = DateTime.new(now.year,now.mon,now.day,rs.start_at.hour,rs.start_at.min)
       end_at = DateTime.new(now.year,now.mon,now.day,rs.end_at.hour,rs.end_at.min)
       if start_at > end_at
         duration.push({
           start_at: start_at,
           end_at: end_at + 1,
           id: rs.id
         })
         duration.push({
           start_at: start_at - 1 ,
           end_at: end_at,
           id: rs.id
         })
       else
         duration.push({
           start_at: start_at,
           end_at: end_at,
           id: rs.id
         })
       end
   end
   duration.each do |rs|
     if rs[:start_at] <= now and rs[:end_at] > now 
       shift_id = rs[:id]
       at_date = rs[:start_at]
     end
   end
    {
      at_date: at_date,
      shift_id: shift_id
    }
  end  
  
end
