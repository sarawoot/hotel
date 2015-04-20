class ReceptionController < ApplicationController
  set_tab :reception
  
  def check_in_index
    search = []
    if params[:search].to_s != ""
      if params[:search][:start_at].to_s != "" and  params[:search][:end_at].to_s != ""
        #search.push("(#{time_overlap("#{date_datesql(params[:search][:start_at])}","#{date_datesql(params[:search][:end_at])}","date(arvl_at)","date(dpt_at)")})")
        search.push("date(arvl_at) between '#{date_datesql(params[:search][:start_at])}' and '#{date_datesql(params[:search][:end_at])}' ")
      end
      search.push("contact_id = #{params[:search][:contact_id]}") if params[:search][:contact_id].to_s != ""
      search.push("ref like '%#{params[:search][:ref]}%'") if params[:search][:ref].to_s != ""
      
    end
    confirm_id = RsvtStatus.where(status: '1').first.id
    search.push("rsvt_status_id = #{confirm_id}")
    search.push("(stay_status = '' or stay_status is null or stay_status = '1' or stay_status = '2')")
    #search.push("stay_status != '0'")
    
    @input_type = InputType.where(hotel_src_id: current_user.hotel_src_id).where(search.join(" and ")).order(:arvl_at).page(params[:page])
  end
  
  def check_in
    @input_type = InputType.find(params[:id])
    @input_type.arvl_at = begin @input_type.arvl_at.strftime("%d/%m/%Y %H:%M") rescue "" end 
    @input_type.dpt_at = begin @input_type.dpt_at.strftime("%d/%m/%Y %H:%M") rescue "" end 
  end
  
  def check_in_action
    @input_type = InputType.find(params[:id])    
    field_name = @input_type.type.underscore   
    
    begin
      InputType.transaction do
        params[:"#{field_name}"][:arvl_at] = datetime_datetimesql(params[:"#{field_name}"][:arvl_at])
        params[:"#{field_name}"][:dpt_at] = datetime_datetimesql(params[:"#{field_name}"][:dpt_at])
        input_type_stay_status = '2' #cancel
        params[:"#{field_name}"][:room_lists_attributes].each {|rl|
          #กรณีลบห้อง
          # ให้ทำห้องที่ลบให้เป็นว่างทำความสะอาดแล้วและข้ามขั้นตอนในรายการห้องนั้นไป
          if rl[1][:_destroy].to_s == "1"
            if rl[1][:room_id].to_s != ""
              room = Room.find(rl[1][:room_id])
              room.status = '1' # ว่างทำความสะอาดแล้ว
              room.save
            end
            #render text: rl[1]
            #return
            next
          end
          #กรณี check out ไปแล้ว
          #ให้ข้ามรายการนี้ไป
          if rl[1][:id].to_s != ""
            if RoomList.find(rl[1][:id]).status == '4' #check out
              next
            end          
          end
          rl[1][:dpt_at] = params[:"#{field_name}"][:dpt_at]
          room_list_status = '6' #cancel
          rl[1][:stay_lists_attributes].each {|s|
            if s[1][:status].to_s == '1' and s[1][:_destroy].to_s == "false" #check in
              room_list_status = '3' #check in
              input_type_stay_status = '1' #check in
            end
          }
          room_id_old = begin RoomList.find(rl[1][:id]).room_id rescue "" end
          #กรณีใส่หมายเลขห้องและ ในห้องมีการ check in
          if rl[1][:room_id].to_s != "" and room_list_status == '3' #check in
            room = Room.find(rl[1][:room_id])
            #กรณีห้องมีคนพัก และปิดซ่อม
            #ให้ออกจากขั้นตอนทั้งหมด
            if ['4','5','0'].include?(room.status) and room_id_old != rl[1][:room_id].to_i
              flash[:notice] = "#{t("html.room_not_available")}(#{t("html.room_no")} #{room.room_no})"
              redirect_to check_in_path(id: params[:id])
              return
            end
            room.status = '4' #มีแขกพักทำความสะอาดแล้ว
            room.save
          end
          #กรณีใส่หมายเลขห้องและ ในห้องไม่มีการ check in
          if rl[1][:room_id].to_s != "" and room_list_status == '6' # ไม่     check in
            room = Room.find(rl[1][:room_id])
            room.status = '1' #ห้องว่างทำความสะอาดแล้ว
            room.save
          end
          # มีการเปลี่ยนห้องและห้องเก่าไม่ว่างเปล่า
          if room_id_old != rl[1][:room_id].to_i and room_id_old.to_s != "" 
            room = Room.find(room_id_old)
            if room.status == '4' #แขกพักทำความสะอาดแล้ว
              room.status = '1' # ว่างทำความสะอาดแล้ว
              room.save
            end
          end
          rl[1][:status] = room_list_status
          tmp_status = begin RoomList.find(rl[1][:id]).status.to_s rescue "" end
          if room_list_status == '3' and tmp_status != "3" #check in
            rl[1][:arvl_by] = current_user.id
            rl[1][:arvl_at] = Time.now
          end
        }
        if params[:"#{field_name}"][:expenses_attributes].to_s != ""
          params[:"#{field_name}"][:expenses_attributes].each {|ep|
            ep[1][:per_unit] = ep[1][:price]
          } 
        end
        params[:"#{field_name}"][:stay_status] = input_type_stay_status
        @input_type.update_attributes(params[:"#{field_name}"])

        folio = Folio.where(input_type_id: @input_type.id).first
        if folio.nil?
          folio = Folio.new 
          folio.input_type_id = @input_type.id
          #folio.folio_no = gen_folio_no
          folio.remark = "Master"
          folio.save
        end
        
        cnt = Expense.where(input_type_id: @input_type.id).count
        if cnt > 0
          Expense.update_all("folio_id=#{folio.id}", "input_type_id = #{@input_type.id}")
        end          
        
        redirect_to check_in_index_path(search: {start_at: date_dateform(Time.now),end_at: date_dateform(Time.now) }), notice: "#{I18n.t "html.update_success"}"
      end  
    rescue
      redirect_to check_in_path(id: params[:id]), notice: "#{I18n.t "html.please_do_again"}" 
    end
  end

end
