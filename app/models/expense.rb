class Expense < ActiveRecord::Base
  attr_accessible :price, :product_id, :room_list_id, :user_id, :vol,
                  :hotel_src_id, :per_unit, :input_type_id, :folio_id,
                  :at_date, :ref, :shift_id
  belongs_to :user
  belongs_to :room_list
  belongs_to :product
  belongs_to :input_type
  belongs_to :folio
  before_create :hotel_src
  before_update :check_payment
  before_destroy :before_delete
  
  def hotel_src
    sh = get_shift
    self.hotel_src_id = User.hotel_src
    self.user_id = User.current_user_id
    self.at_date = sh[:at_date]
    self.shift_id = sh[:shift_id]
    if self.product_id.to_s != ""
      pd = Product.find(self.product_id).config
      if pd.to_s == '4'
        self.price = self.price.to_f.abs*-1
        self.per_unit = self.per_unit.to_f.abs*-1
      end
    end
  end
  
  def check_payment
    if self.product_id.to_s != ""
      pd = Product.find(self.product_id).config
      if pd.to_s == '4'
        self.price = self.price.to_f.abs*-1
        self.per_unit = self.per_unit.to_f.abs*-1
      end
    end
    if self.changed?
      rs = LogExpense.new
      old = Expense.find(self.id)
      rs.expense_id = old.id
      rs.room_list_id = old.room_list_id   
      rs.product_id = old.product_id
      rs.price = old.price
      rs.per_unit = old.per_unit
      rs.user_id = old.user_id
      rs.vol = old.vol
      rs.hotel_src_id = old.hotel_src_id
      rs.input_type_id = old.input_type_id
      rs.folio_id = old.folio_id
      rs.at_date = old.at_date
      rs.ref = old.ref
      rs.shift_id = old.shift_id
      rs.act = "update"
      rs.save
    end
  end
  
  def before_delete
      rs = LogExpense.new
      old = Expense.find(self.id)
      rs.expense_id = old.id
      rs.room_list_id = old.room_list_id   
      rs.product_id = old.product_id
      rs.price = old.price
      rs.per_unit = old.per_unit
      rs.user_id = old.user_id
      rs.vol = old.vol
      rs.hotel_src_id = old.hotel_src_id
      rs.input_type_id = old.input_type_id
      rs.folio_id = old.folio_id
      rs.at_date = old.at_date
      rs.ref = old.ref
      rs.shift_id = old.shift_id
      rs.act = "delete"
      rs.save    
  end
  
  
  private
  
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
