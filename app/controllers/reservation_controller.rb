class ReservationController < ApplicationController
  set_tab :rsvt
  def reservation_index
    search = []
    if params[:search].to_s != ""
      if params[:search][:start_at].to_s != "" and  params[:search][:end_at].to_s != ""
        #search.push("(#{time_overlap("#{date_datesql(params[:search][:start_at])}","#{date_datesql(params[:search][:end_at])}","date(arvl_at)","date(dpt_at)")})")
        search.push("date(arvl_at) between '#{date_datesql(params[:search][:start_at])}' and '#{date_datesql(params[:search][:end_at])}' ")
      end
      search.push("rsvt_status_id = #{params[:search][:rsvt_status_id]}") if params[:search][:rsvt_status_id].to_s != ""
      search.push("contact_id = #{params[:search][:contact_id]}") if params[:search][:contact_id].to_s != ""
      search.push("ref like '%#{params[:search][:ref]}%'") if params[:search][:ref].to_s != ""
    end
    search.push("(stay_status = '' or stay_status is null or stay_status = '2' )")
    @input_type = InputType.where(hotel_src_id: current_user.hotel_src_id, type: ['BookingGrp','BookingIdv']).where(search.join(" and ")).order(:arvl_at).page(params[:page])
  end
end
