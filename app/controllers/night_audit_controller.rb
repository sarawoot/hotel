class NightAuditController < ApplicationController
  def night_audit_action    
    now = Time.now
    room_rate = Product.select(:id).where(config: '1').first
    ext_bed_rate = Product.select(:id).where(config: '2').first
    abf_rate = Product.select(:id).where(config: '3').first
    
    room_lists = RoomList.where(status: '3')
    room_lists.each {|rl|
      Room.update(rl.room_id, status: '5')
      folio = Folio.where(input_type_id: rl.input_type_id).order(:id).first
      stay_list = StayList.select("sum(ext_bed_rate) as ext_bed_rate,sum(abf_rate) as abf_rate")
                   .where(room_list_id: rl.id).first
                   
      Expense.create({folio_id: folio.id,input_type_id: rl.input_type_id,room_list_id: rl.id,product_id: room_rate.id,price: rl.room_rate,per_unit: rl.room_rate,vol: 1,user_id: current_user.id,at_date: now})
      if stay_list.ext_bed_rate.to_f != 0.0
        Expense.create({
          folio_id: folio.id,
          input_type_id: rl.input_type_id,
          room_list_id: rl.id,
          product_id: ext_bed_rate.id,
          price: stay_list.ext_bed_rate,
          per_unit: stay_list.ext_bed_rate,
          vol: StayList.where("room_list_id = #{rl.id} and ext_bed_rate != 0").count,
          user_id: current_user.id,
          at_date: now})         
      end
      if stay_list.abf_rate.to_f != 0.0
        Expense.create({
          folio_id: folio.id,
          input_type_id: rl.input_type_id,
          room_list_id: rl.id,
          product_id: abf_rate.id,
          price: stay_list.abf_rate,
          per_unit: stay_list.abf_rate,
          vol: StayList.where("room_list_id = #{rl.id} and abf_rate != 0").count,
          user_id: current_user.id,
          at_date: now})         
      end
    }
    redirect_to root_url, notice: "#{I18n.t "html.save_success"}"
  end
end
