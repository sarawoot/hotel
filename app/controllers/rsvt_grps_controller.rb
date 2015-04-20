class RsvtGrpsController < ApplicationController
  set_tab :rsvt
  
  def new
    @booking_grp = BookingGrp.new
    1.times {@booking_grp.room_lists.build}
  end
  
  def create
    @booking_grp = BookingGrp.new(params[:booking_grp])
    room_tmp = []
    params[:booking_grp][:room_lists_attributes].each {|rl|
      if rl[1][:_destroy].to_s == "false"
        room_tmp.push(rl[1][:room_id])
      end
    }
    #if room_tmp.length != room_tmp.uniq.length
    #  flash[:alert] = "#{t("html.please_do_again")}"
    #  render action: "new"
    #  return
    #end
    
    params[:booking_grp][:arvl_at] = datetime_datetimesql(params[:booking_grp][:arvl_at])
    params[:booking_grp][:dpt_at] = datetime_datetimesql(params[:booking_grp][:dpt_at])
    begin
      params[:booking_grp][:room_lists_attributes].each {|rl|
        rl[1][:arvl_at] = params[:booking_grp][:arvl_at]
        rl[1][:dpt_at] = params[:booking_grp][:dpt_at]
        rsvt_status = begin
          RsvtStatus.find(params[:booking_grp][:rsvt_status_id]).status
        rescue
          ""
        end
        if rsvt_status.to_s == "1" #confirmation
          rl[1][:status] = '1' # reservation
        end
        if rsvt_status.to_s == "0" #cancel
          rl[1][:status] = '2' # cancel_reservation
        end
        if rsvt_status.to_s == "2" #in_process
          rl[1][:status] = '5' #in_process
        end
      }
      params[:booking_grp][:expenses_attributes].each {|ep|
          ep[1][:per_unit] = ep[1][:price]
      }
    rescue
      ""
    end
    params[:booking_grp][:input_by] = current_user.id
    @booking_grp = BookingGrp.new(params[:booking_grp])
    respond_to do |format|
      if @booking_grp.save
        cnt = Expense.where(input_type_id: @booking_grp.id).count
        if cnt > 0
          folio = Folio.where(input_type_id: @booking_grp.id).first
          if folio.nil?
            folio = Folio.new 
            folio.input_type_id = @booking_grp.id
            #folio.folio_no = gen_folio_no
            folio.remark = "Master"
            folio.save
          end
          Expense.update_all("folio_id=#{folio.id}", "input_type_id = #{@booking_grp.id}")
        end
        format.html { redirect_to reservation_index_path(search: {start_at: date_dateform(Time.now),end_at: date_dateform(Time.now) }), notice: "#{I18n.t "html.save_success"}" }
      else
        format.html { render action: "new" }
      end
    end
  end
  
  def edit
    @booking_grp = BookingGrp.find(params[:id])
    @booking_grp.arvl_at = begin @booking_grp.arvl_at.strftime("%d/%m/%Y %H:%M")  rescue "" end 
    @booking_grp.dpt_at = begin @booking_grp.dpt_at.strftime("%d/%m/%Y %H:%M")  rescue "" end 
  end
  
  def update
    @booking_grp = BookingGrp.find(params[:id])
    room_tmp = []
    params[:booking_grp][:room_lists_attributes].each {|rl|
      room_tmp.push(rl[1][:room_id])
    }
    #if room_tmp.length != room_tmp.uniq.length
    #  @booking_grp.arvl_at = begin @booking_grp.arvl_at.strftime("%d/%m/%Y %H:%M")  rescue "" end 
    #  @booking_grp.dpt_at = begin @booking_grp.dpt_at.strftime("%d/%m/%Y %H:%M")  rescue "" end 
    #  flash[:alert] = "#{t("html.please_do_again")}"
    #  render action: "edit"
    #  return
    #end
    
    params[:booking_grp][:arvl_at] = datetime_datetimesql(params[:booking_grp][:arvl_at])
    params[:booking_grp][:dpt_at] = datetime_datetimesql(params[:booking_grp][:dpt_at])
    begin
      params[:booking_grp][:room_lists_attributes].each {|rl|
        rl[1][:arvl_at] = params[:booking_grp][:arvl_at]
        rl[1][:dpt_at] = params[:booking_grp][:dpt_at]
        rsvt_status = begin
          RsvtStatus.find(params[:booking_grp][:rsvt_status_id]).status
        rescue
          ""
        end
        if rsvt_status.to_s == "1" #confirmation
          rl[1][:status] = '1' # reservation
        end
        if rsvt_status.to_s == "0" #cancel
          rl[1][:status] = '2' # cancel_reservation
        end
        if rsvt_status.to_s == "2" #in_process
          rl[1][:status] = '5' #in_process
        end
      }
      if params[:booking_grp][:expenses_attributes].to_s != ""
        params[:booking_grp][:expenses_attributes].each {|ep|
          ep[1][:per_unit] = ep[1][:price]
        } 
      end
    rescue
      ""
    end
    
    
    respond_to do |format|      
      if @booking_grp.update_attributes(params[:booking_grp])
        
        cnt = Expense.where(input_type_id: @booking_grp.id).count
        if cnt > 0
          folio = Folio.where(input_type_id: @booking_grp.id).first
          if folio.nil?
            folio = Folio.new 
            folio.input_type_id = @booking_grp.id
            #folio.folio_no = gen_folio_no
            folio.remark = "Master"
            folio.save
          end
          Expense.update_all("folio_id=#{folio.id}", "input_type_id = #{@booking_grp.id}")
        end        
        
        format.html { redirect_to reservation_index_path(search: {start_at: date_dateform(Time.now),end_at: date_dateform(Time.now) }), notice: "#{I18n.t "html.update_success"}" }
      else
        format.html { render action: "edit" }
      end
    end
  end
  

end

