class RsvtIdvsController < ApplicationController
  set_tab :rsvt
  def index
    search = []
    if params[:search].to_s != ""
      if params[:search][:start_at].to_s != "" and  params[:search][:end_at].to_s != ""
        search.push(" arvl_at between '#{date_datesql(params[:search][:start_at])}' and '#{date_datesql(params[:search][:end_at])}'")
      end
      search.push("rsvt_status_id = #{params[:search][:rsvt_status_id]}") if params[:search][:rsvt_status_id].to_s != ""
      search.push("contact_id = #{params[:search][:contact_id]}") if params[:search][:contact_id].to_s != ""
      search.push("ref like '%#{params[:search][:ref]}%'") if params[:search][:ref].to_s != ""

    end
    @booking_idv = BookingIdv.where(hotel_src_id: current_user.hotel_src_id).where(search.join(" and ")).order(:arvl_at).page(params[:page])
  end
  
  def new
    @booking_idv = BookingIdv.new
    1.times {@booking_idv.room_lists.build}
  end
  
  def create
    params[:booking_idv][:arvl_at] = datetime_datetimesql(params[:booking_idv][:arvl_at])
    params[:booking_idv][:dpt_at] = datetime_datetimesql(params[:booking_idv][:dpt_at])
    begin
      params[:booking_idv][:room_lists_attributes].each {|rl|
        rl[1][:arvl_at] = params[:booking_idv][:arvl_at]
        rl[1][:dpt_at] = params[:booking_idv][:dpt_at]
        rsvt_status = begin
          RsvtStatus.find(params[:booking_idv][:rsvt_status_id]).status
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
      params[:booking_idv][:expenses_attributes].each {|ep|
          ep[1][:per_unit] = ep[1][:price]
      }      
    rescue
      ""
    end
    

    
    params[:booking_idv][:input_by] = current_user.id
    @booking_idv = BookingIdv.new(params[:booking_idv])
    respond_to do |format|
      if @booking_idv.save
        
        cnt = Expense.where(input_type_id: @booking_idv.id).count
       
        
        if cnt > 0
          folio = Folio.where(input_type_id: @booking_idv.id).first
          if folio.nil?
            folio = Folio.new 
            folio.input_type_id = @booking_idv.id
            #folio.folio_no = gen_folio_no
            folio.remark = "Master"
            folio.save
          end
          Expense.update_all("folio_id=#{folio.id}", "input_type_id = #{@booking_idv.id}")
        end
        
        
        format.html { redirect_to reservation_index_path(search: {start_at: date_dateform(Time.now),end_at: date_dateform(Time.now) }), notice: "#{I18n.t "html.save_success"}" }
      else
        format.html { render action: "new" }
      end
    end
  end
  
  def edit
    @booking_idv = BookingIdv.find(params[:id])
    @booking_idv.arvl_at = begin @booking_idv.arvl_at.strftime("%d/%m/%Y %H:%M") rescue "" end 
    @booking_idv.dpt_at = begin @booking_idv.dpt_at.strftime("%d/%m/%Y %H:%M") rescue "" end 
  end
  
  def update
    params[:booking_idv][:arvl_at] = datetime_datetimesql(params[:booking_idv][:arvl_at])
    params[:booking_idv][:dpt_at] = datetime_datetimesql(params[:booking_idv][:dpt_at])
    begin
      params[:booking_idv][:room_lists_attributes].each {|rl|
        rl[1][:arvl_at] = params[:booking_idv][:arvl_at]
        rl[1][:dpt_at] = params[:booking_idv][:dpt_at]
        
        rsvt_status = begin
          RsvtStatus.find(params[:booking_idv][:rsvt_status_id]).status
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
      if params[:booking_idv][:expenses_attributes].to_s != ""
        params[:booking_idv][:expenses_attributes].each {|ep|
          ep[1][:per_unit] = ep[1][:price]
        } 
      end      
    rescue
      ""
    end
    
    @booking_idv = BookingIdv.find(params[:id])
    respond_to do |format|
      if @booking_idv.update_attributes(params[:booking_idv])
        
        cnt = Expense.where(input_type_id: @booking_idv.id).count
        if cnt > 0
          folio = Folio.where(input_type_id: @booking_idv.id).first
          if folio.nil?
            folio = Folio.new 
            folio.input_type_id = @booking_idv.id
            #folio.folio_no = gen_folio_no
            folio.remark = "Master"
            folio.save
          end
          Expense.update_all("folio_id=#{folio.id}", "input_type_id = #{@booking_idv.id}")
        end         
        
        format.html { redirect_to reservation_index_path(search: {start_at: date_dateform(Time.now),end_at: date_dateform(Time.now) }), notice: "#{I18n.t "html.update_success"}" }
      else
        format.html { render action: "edit" }
      end
    end
  end
  

end
