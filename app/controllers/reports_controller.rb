class ReportsController < ApplicationController
  set_tab :report
  def rsvt_forecast
    search = []
    if params[:search].to_s != ""
      if params[:search][:start_at].to_s != "" and  params[:search][:end_at].to_s != ""
        search.push(time_overlap("#{date_datesql(params[:search][:start_at])}",
                                  "#{date_datesql(params[:search][:end_at])}",
                                  "room_lists.arvl_at",
                                  "room_lists.dpt_at")  )
      end
      search.push("room_lists.status = '#{params[:search][:status]}'") if params[:search][:status].to_s != ""
      search.push("room_lists.room_id = '#{params[:search][:room_id]}'") if params[:search][:room_id].to_s != ""
      search.push("rooms.room_type_id = '#{params[:search][:room_type_id]}'") if params[:search][:room_type_id].to_s != ""
      search.push("rooms.floor_id = '#{params[:search][:floor_id]}'") if params[:search][:floor_id].to_s != ""
    end
    @room_lists = RoomList.joins(:room).where(search.join(" and " )).order(:arvl_at).page(params[:page])
  end
  
  def gst_his
    search = []
    begin
      search.push("input_types.contact_id = '#{params[:search][:contact_id]}'") if params[:search][:contact_id].to_s != ""
      search.push("rooms.room_type_id = '#{params[:search][:room_type_id]}'") if params[:search][:room_type_id].to_s != ""
      
      search.push("stay_lists.fname like '%#{params[:search][:fname]}%'") if params[:search][:fname].to_s != ""
      search.push("stay_lists.lname like '%#{params[:search][:lname]}%'") if params[:search][:lname].to_s != ""
    rescue
      ""
    end
    sl = "room_lists.arvl_at,
          room_lists.dpt_at,
          contacts.name as contact_name,
          stay_lists.fname||' '||stay_lists.lname as guest_name,
          rooms.room_no,
          room_types.short_name as room_type_name,
          room_lists.status,
          room_lists.room_rate,
          stay_lists.abf_rate,
          stay_lists.ext_bed_rate"
    @room_lists = RoomList.select(sl).joins(:input_type,:room, :stay_lists, :contact, :room_type).where(status: ['3','4']).where(search.join(" and ")).order("room_lists,rooms.seq").page(params[:page])
  end
  
  def transaction_report
    if params[:search][:report_type].to_s != ""# 1=charge 2=payment
      start_date = dateform_date(params[:search][:start_at]).to_i*1000
      end_date = dateform_date(params[:search][:end_at]).to_i*1000
      url = case params[:search][:report_type].to_s
      when "1"
        url = "transaction_charge"
      when "2"
        url = "transaction_payment"
      else
        ""
      end
      if url != ""
        data = JasperReport.run_report({
          report: "reports/hotel/#{url}",
          format: "pdf",
          params: {
            start_date: start_date,
            end_date: end_date,
            user_id: current_user.id,
            shift_id: params[:search][:shift_id]
          }
        })     
        mime = Mime::Type.lookup_by_extension("pdf").to_s
        send_data(data, :type => mime, :disposition => "inline"  )               
      end
    end
  end
  
  def summary_transaction_report
    if params[:search][:report_type].to_s == '1'
      start_date = dateform_date(params[:search][:start_at]).to_i*1000
      end_date = dateform_date(params[:search][:end_at]).to_i*1000
      url = "summary_transaction"
      data = JasperReport.run_report({
        report: "reports/hotel/#{url}",
        format: "pdf",
        params: {
          start_date: start_date,
          end_date: end_date,
          user_id: current_user.id,
          shift_id: params[:search][:shift_id]
        }
      })     
      mime = Mime::Type.lookup_by_extension("pdf").to_s
      send_data(data, :type => mime, :disposition => "inline"  )
    end
  end
  
  def guest_in_house
    if params[:search][:report_type].to_s != ""# 1=cashier 2=housekeeping
      start_date = dateform_date(params[:search][:start_at]).to_i*1000
      end_date = dateform_date(params[:search][:end_at]).to_i*1000
      url = case params[:search][:report_type].to_s
      when "1"
        url = "guest_in_house"
      when "2"
        url = "guest_in_house_maid"
      else
        ""
      end
      if url != ""
        data = JasperReport.run_report({
          report: "reports/hotel/#{url}",
          format: "pdf",
          params: {
            start_date: start_date,
            end_date: end_date,
            user_id: current_user.id,
            shift_id: params[:search][:shift_id]
          }
        })     
        mime = Mime::Type.lookup_by_extension("pdf").to_s
        send_data(data, :type => mime, :disposition => "inline"  )               
      end
    end
  end

  def report_out_standing
    at_date = date_datesql(params[:search][:at_date])
    if at_date.to_s == ""
      render text: ""
      return
    end
    if params[:report].to_s == "1"
      #######################
      # ลูกหนี้ ตามที่จอง และ walk in
      #######################
      sql = "
        select
          0 as report,
          null as room,
          null as room_type,
          gst_types.name as gst_type,
          contacts.name as gst_name,
          date(input_types.arvl_at) as arvl_at,
          date(input_types.dpt_at) as dpt_at,
          null as room_rate,
          null as ext_bed_rate,
          (select abs(sum(expenses.price)) from folios,expenses, products where folios.input_type_id = input_types.id and folios.id = expenses.folio_id and expenses.product_id = products.id and products.config != '4') as folio,
          (select abs(sum(expenses.price)) from folios,expenses, products where folios.input_type_id = input_types.id and folios.id = expenses.folio_id and expenses.product_id = products.id and products.config = '4') as credit
        from
          input_types
          left join gst_types on gst_types.id = input_types.gst_type_id
          left join contacts on contacts.id = input_types.contact_id
        where
          input_types.stay_status = '0' and 
          COALESCE((select abs(sum(expenses.price)) from folios,expenses, products where folios.input_type_id = input_types.id and folios.id = expenses.folio_id and expenses.product_id = products.id and products.config != '4'), 0) -
          COALESCE((select abs(sum(expenses.price)) from folios,expenses, products where folios.input_type_id = input_types.id and folios.id = expenses.folio_id and expenses.product_id = products.id and products.config = '4'), 0)  != 0
      "
      rs = InputType.find_by_sql(sql)
      rs.each {|u|
        OutStanding.create({
            report: u.report,
            room: u.room,
            room_type: u.room_type,
            gst_type: u.gst_type,
            gst_name: u.gst_name,
            arvl_at: u.arvl_at,
            dpt_at: u.dpt_at,
            room_rate: u.room_rate,
            ext_bed_rate: u.ext_bed_rate,
            folio: u.folio,
            credit: u.credit
        })
      }
      ##########################################
      # ลูกหนี้ ตาม folio ที่มาจ่าย cashier sell
      ##########################################
      sql = "
        select
          0 as report,
          null as room,
          null as room_type,
          null as gst_type,
          folios.folio_no as gst_name,
          null as arvl_at,
          null as dpt_at,
          null as room_rate,
          null as ext_bed_rate,
          (select abs(sum(expenses.price)) from expenses, products where expenses.folio_id = folios.id and expenses.product_id = products.id and products.config != '4') as folio,
          (select abs(sum(expenses.price)) from expenses, products where expenses.folio_id = folios.id and expenses.product_id = products.id and products.config = '4') as credit
        from 
          folios
        where
          COALESCE((select abs(sum(expenses.price)) from expenses, products where expenses.folio_id = folios.id and expenses.product_id = products.id and products.config != '4'),0) - 
          COALESCE((select abs(sum(expenses.price)) from expenses, products where expenses.folio_id = folios.id and expenses.product_id = products.id and products.config = '4'),0) != 0 and
          folios.input_type_id is null;
      "
      rs = InputType.find_by_sql(sql)
      rs.each {|u|
        OutStanding.create({
            report: u.report,
            room: u.room,
            room_type: u.room_type,
            gst_type: u.gst_type,
            gst_name: u.gst_name,
            arvl_at: u.arvl_at,
            dpt_at: u.dpt_at,
            room_rate: u.room_rate,
            ext_bed_rate: u.ext_bed_rate,
            folio: u.folio,
            credit: u.credit
        })
      }
      ##################################
      # ตามที่ยังพักอยู่
      ##################################
      
      rs = InputType.select("distinct input_types.id").joins(:room_lists)
            .where("input_types.hotel_src_id = #{current_user.hotel_src_id} and input_types.stay_status = '1' and '#{at_date}' between date(room_lists.arvl_at) and date(room_lists.dpt_at)" )
      rs.each {|u|
        ######################
        sql = "
          select 
            1 as report,
            rooms.room_no as room,
            room_types.short_name as room_type,
            gst_types.name as gst_type,
            contacts.name as gst_name,
            date(input_types.arvl_at) as arvl_at,
            date(input_types.dpt_at) as dpt_at,
            COALESCE(room_lists.room_rate,0)  + COALESCE((select sum(abf_rate) from stay_lists where stay_lists.room_list_id = room_lists.id),0) as room_rate,
            (select sum(ext_bed_rate) from stay_lists where stay_lists.room_list_id = room_lists.id) as ext_bed_rate,
            (select abs(sum(expenses.price)) from expenses left join products on  expenses.product_id = products.id left join folios on expenses.folio_id = folios.id where  expenses.input_type_id = #{u.id} and products.config != '4') as folio
          from 
            room_lists 
            left join input_types on input_types.id = room_lists.input_type_id
            left join rooms on rooms.id = room_lists.room_id
            left join room_types on room_types.id = rooms.room_type_id
            left join gst_types on gst_types.id = input_types.gst_type_id
            left join contacts on contacts.id = input_types.contact_id
          where 
            room_lists.status = '3'  and
            '#{at_date}' between date(room_lists.arvl_at) and date(room_lists.dpt_at) and
            room_lists.input_type_id = #{u.id}    
        "
        report = InputType.find_by_sql(sql)
        
        ###########################
        sql = "
          select count(*) as cnt from room_lists where room_lists.input_type_id = #{u.id}
        "
        room_cnt = InputType.find_by_sql(sql).first.cnt
        
        ###########################
        sql = "
          select
            abs(sum(expenses.price)) as credit
          from
            expenses, products, folios
          where
            folios.input_type_id = #{u.id} and
            expenses.folio_id = folios.id and
            expenses.product_id = products.id and
            products.config = '4'
        "
        credit = InputType.find_by_sql(sql).first.credit
        ############################
        payment = share_payment(report.collect{|u| u.folio.to_f}, credit.to_f)
        i = 0
        report.each {|u|
          OutStanding.create({
              report: u.report,
              room: u.room,
              room_type: u.room_type,
              gst_type: u.gst_type,
              gst_name: u.gst_name,
              arvl_at: u.arvl_at,
              dpt_at: u.dpt_at,
              room_rate: u.room_rate,
              ext_bed_rate: u.ext_bed_rate,
              folio: u.folio,
              credit: payment[i][1]
          })
          i += 1
        } 
      }
      
      
      
      
      ##########################################
      # ตาม folio ที่มาจ่าย cashier sell แล้วจ่ายครบ
      ##########################################
      sql = "
        select
          1 as report,
          null as room,
          null as room_type,
          null as gst_type,
          folios.folio_no as gst_name,
          null as arvl_at,
          null as dpt_at,
          null as room_rate,
          null as ext_bed_rate,
          (select abs(sum(expenses.price)) from expenses, products where expenses.folio_id = folios.id and expenses.product_id = products.id and products.config != '4') as folio,
          (select abs(sum(expenses.price)) from expenses, products where expenses.folio_id = folios.id and expenses.product_id = products.id and products.config = '4') as credit
        from 
          folios
        where
          COALESCE((select abs(sum(expenses.price)) from expenses, products where expenses.folio_id = folios.id and expenses.product_id = products.id and products.config != '4'),0) - 
          COALESCE((select abs(sum(expenses.price)) from expenses, products where expenses.folio_id = folios.id and expenses.product_id = products.id and products.config = '4'),0) = 0 and
          folios.input_type_id is null and
          folios.at_date = '#{at_date}';
      "
      rs = InputType.find_by_sql(sql)
      rs.each {|u|
        OutStanding.create({
            report: u.report,
            room: u.room,
            room_type: u.room_type,
            gst_type: u.gst_type,
            gst_name: u.gst_name,
            arvl_at: u.arvl_at,
            dpt_at: u.dpt_at,
            room_rate: u.room_rate,
            ext_bed_rate: u.ext_bed_rate,
            folio: u.folio,
            credit: u.credit
        })
      }      
      
      
      
      
      data = JasperReport.run_report({
        report: "reports/hotel/out_standing",
        format: "pdf",
        params: {
          at_date: dateform_date(params[:search][:at_date]).to_i*1000,
          user_id: current_user.id
        }
      })     
      mime = Mime::Type.lookup_by_extension("pdf").to_s
      send_data(data, :type => mime, :disposition => "inline"  )         
      
      
      OutStanding.delete_all()
    end # params[:report].to_s == "1"
    
  end
  
  def report_trial_balance
    if params[:search][:at_date].to_s == ""
      render text: ""
      return
    end
    if params[:report].to_s == "1"
      data = JasperReport.run_report({
        report: "reports/hotel/trial_balance",
        format: "pdf",
        params: {
          at_date: dateform_date(params[:search][:at_date]).to_i*1000,
          user_id: current_user.id
        }
      })     
      mime = Mime::Type.lookup_by_extension("pdf").to_s
      send_data(data, :type => mime, :disposition => "inline"  ) 
    end
  end
  
  def report_abf
    if params[:search][:start_date].to_s == "" or params[:search][:end_date].to_s == ""
      render text: ""
      return
    end
    if params[:report].to_s == "1"
      data = JasperReport.run_report({
        report: "hotel/report/abf",
        format: "pdf",
        params: {
          start_date: dateform_date(params[:search][:start_date]),
          end_date: dateform_date(params[:search][:end_date]),
          user_id: current_user.id
        }
      })     
      mime = Mime::Type.lookup_by_extension("pdf").to_s
      send_data(data, :type => mime, :disposition => "inline"  ) 
    end
  end
  
  def report_move_room
    if params[:search][:start_date].to_s == "" or params[:search][:end_date].to_s == ""
      render text: ""
      return
    end
    if params[:report].to_s == "1"
      data = JasperReport.run_report({
        report: "reports/hotel/move_room",
        format: "pdf",
        params: {
          start_date: dateform_date(params[:search][:start_date]).to_i*1000,
          end_date: dateform_date(params[:search][:end_date]).to_i*1000,
          user_id: current_user.id
        }
      })     
      mime = Mime::Type.lookup_by_extension("pdf").to_s
      send_data(data, :type => mime, :disposition => "inline"  ) 
    end    
  end
  
  def report_check_out
    if params[:search][:start_date].to_s == "" or params[:search][:end_date].to_s == ""
      render text: ""
      return
    end
    if params[:report].to_s == "1"
      data = JasperReport.run_report({
        report: "reports/hotel/check_out",
        format: "pdf",
        params: {
          start_date: dateform_date(params[:search][:start_date]).to_i*1000,
          end_date: dateform_date(params[:search][:end_date]).to_i*1000,
          user_id: current_user.id
        }
      })     
      mime = Mime::Type.lookup_by_extension("pdf").to_s
      send_data(data, :type => mime, :disposition => "inline"  ) 
    end      
  end
end
