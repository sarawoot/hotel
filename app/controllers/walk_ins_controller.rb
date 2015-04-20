class WalkInsController < ApplicationController
  set_tab :reception
  
  def new
    @walk_in = WalkIn.new
    1.times {@walk_in.room_lists.build}
    @walk_in.rsvt_status_id = RsvtStatus.where(status: '1').first.id
  end
  
  def create
    @walk_in = WalkIn.new(params[:walk_in])
    room_tmp = []
    params[:walk_in][:room_lists_attributes].each {|rl|
      if rl[1][:_destroy].to_s == "false"
        room_tmp.push(rl[1][:room_id])
      end
    }
    #if room_tmp.length != room_tmp.uniq.length or room_tmp.include?("")
    #  flash[:alert] = "#{t("html.please_do_again")}"
    #  render action: "new"
    #  return
    #end  

    cnt_ = Room.where(status: ['4', '5'], id: room_tmp).count
    if cnt_ > 0
      flash[:alert] = "Room not valid. Please try again."    
      render action: "new"
      return
    end    
    
    params[:walk_in][:arvl_at] = datetime_datetimesql(params[:walk_in][:arvl_at])
    params[:walk_in][:dpt_at] = datetime_datetimesql(params[:walk_in][:dpt_at])
    params[:walk_in][:stay_status] = '1' # check_in
    begin
      params[:walk_in][:room_lists_attributes].each {|rl|
        rl[1][:arvl_at] = params[:walk_in][:arvl_at]
        rl[1][:arvl_by] = current_user.id
        rl[1][:dpt_at] = params[:walk_in][:dpt_at]
        rl[1][:status] = '3' # check_in
        rl[1][:stay_lists_attributes].each {|sl|
          sl[1][:status] = '1' # check_in
        }
        room = Room.find(rl[1][:room_id]) 
        room.status = '4'
        room.save
      }
      params[:walk_in][:expenses_attributes].each {|ep|
        ep[1][:per_unit] = ep[1][:price]
      }
    rescue
      ""
    end
    params[:walk_in][:input_by] = current_user.id
    @walk_in = WalkIn.new(params[:walk_in])
    respond_to do |format|
      if @walk_in.save
        cnt = Expense.where(input_type_id: @walk_in.id).count
        folio = Folio.where(input_type_id: @walk_in.id).first
        if folio.nil?
          folio = Folio.new 
          folio.input_type_id = @walk_in.id
          #folio.folio_no = gen_folio_no
          folio.remark = "Master"
          folio.save
        end        
        if cnt > 0
          Expense.update_all("folio_id=#{folio.id}", "input_type_id = #{@walk_in.id}")
        end        
        
        format.html { redirect_to check_in_index_path(search: {start_at: date_dateform(Time.now),end_at: date_dateform(Time.now) }), notice: "#{I18n.t "html.save_success"}" }
      else
        format.html { render action: "new" }
      end
    end
  end
end
