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
      start_date = date_datesql(params[:search][:start_at])
      end_date = date_datesql(params[:search][:end_at])
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
          report: "hotel/report/#{url}",
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
      start_date = date_datesql(params[:search][:start_at])
      end_date = date_datesql(params[:search][:end_at])
      user_id = current_user.id
      shift_id = params[:search][:shift_id]

      sql = "
      (
        select
          1 as seq,
          print_at,
          username,
          shift_name,
          product_place,
          count(room_list_id) as room_list_id,
          sum(amount) as  amount,
          sum(payment) as payment ,
          count(1) as vol
        from (
          select
            now() as print_at,
            (select fname||'  '||lname from users where users.id = #{user_id}) as username,
            shifts.name as shift_name,
            'Room Charge' as product_place,
            expenses.room_list_id,
            sum(expenses.price) as amount,
            sum(0.00) as payment
          from
            expenses
            left join products on products.id = expenses.product_id
            left join product_places on product_places.id = products.product_place_id
            left join shifts on shifts.id = expenses.shift_id
          where
            products.config in ('1','2','3') and
            expenses.at_date between '#{start_date}' and '#{end_date}' and
            expenses.shift_id = #{shift_id}
          group by
            shift_name,
            product_place,
            expenses.room_list_id,
            print_at,
            username
          order by
            shift_name
        ) as tb1
        group by
          shift_name,
          product_place,
          print_at,
          username
      )
      union
      (
          select
            2 as seq,
            now() as print_at,
            (select fname||'  '||lname from users where users.id = #{user_id}) as username,
            shifts.name as shift_name,
            product_places.name as product_place,
            count(room_list_id) as room_list_id,
            sum(expenses.price) as amount,
            sum(0.00) as payment,
            sum(vol) as vol
          from
            expenses
            left join products on products.id = expenses.product_id
            left join product_places on product_places.id = products.product_place_id
            left join shifts on shifts.id = expenses.shift_id
          where
            products.config not in ('1','2','3', '4')  and
            expenses.at_date between '#{start_date}' and '#{end_date}' and
            expenses.shift_id = #{shift_id}
          group by
            shift_name,
            product_place,
            print_at,
            username
          order by
            shift_name
      )
      union
      (
          select
            3 as seq,
            now() as print_at,
            (select fname||'  '||lname from users where users.id = #{user_id}) as username,
            shifts.name as shift_name,
            product_places.name as product_place,
            count(room_list_id) as room_list_id,
            sum(0.00) as amount,
            sum(abs(expenses.price)) as payment,
            sum(vol) as vol
          from
            expenses
            left join products on products.id = expenses.product_id
            left join product_places on product_places.id = products.product_place_id
            left join shifts on shifts.id = expenses.shift_id
          where
            products.config = '4'  and
            expenses.at_date between '#{start_date}' and '#{end_date}' and
            expenses.shift_id = #{shift_id}
          group by
            shift_name,
            product_place,
            print_at,
            username
          order by
            shift_name
      ) order by shift_name,seq
      "
      SummaryTransaction.delete_all()
      rs = Expense.find_by_sql(sql)
      rs.each {|u|
        SummaryTransaction.create({
          seq: u.seq,
          username: u.username,
          shift_name: u.shift_name,
          product_place: u.product_place,
          room_list_id: u.room_list_id,
          amount: u.amount,
          payment: u.payment,
          vol: u.vol,
        })
      }

      data = JasperReport.run_report({
        report: "hotel/report/summary_transaction",
        format: "pdf",
        params: {
          start_date: date_datesql(params[:search][:start_at]),
          end_date: date_datesql(params[:search][:end_at]),
        }
      })     
      mime = Mime::Type.lookup_by_extension("pdf").to_s
      send_data(data, :type => mime, :disposition => "inline"  )
    end
  end
  
  def guest_in_house
    if params[:search][:report_type].to_s != ""# 1=cashier 2=housekeeping
      start_date = date_datesql(params[:search][:start_at])
      end_date = date_datesql(params[:search][:end_at])
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
          report: "hotel/report/#{url}",
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
    if params[:search][:at_date] == ""
      render text: ""
      return
    end
    if params[:report].to_s == "1"
      data = JasperReport.run_report({
        report: "hotel/report/out_standing",
        format: "pdf",
        params: {
          at_date: date_datesql(params[:search][:at_date]),
          user_id: current_user.id
        }
      })     
      mime = Mime::Type.lookup_by_extension("pdf").to_s
      send_data(data, :type => mime, :disposition => "inline"  )
    end
  end
  
  def report_trial_balance
    if params[:search][:at_date].to_s == ""
      render text: ""
      return
    end
    if params[:report].to_s == "1"
      at_date = date_datesql(params[:search][:at_date])
      user_id = current_user.id
      sql = "
      (
      select
        1 as seq,
        products.name as product_name,
        products.id as products_id,
        sum(expenses.price) as debit,
        null as credit,
        (select fname||'  '||lname from users where users.id = #{user_id}) as username,
        now() as print_at
      from
        expenses
        left join products on products.id = expenses.product_id
      where
        expenses.at_date = '#{at_date}' and
        products.config != '4'
      group by
        product_name,
        products_id,
        username,
        print_at
      order by products_id
      )
      union
      (
      select
        2 as seq,
        products.name as product_name,
        products.id as products_id,
        null as debit,
        abs(sum(expenses.price)) as credit,
        (select fname||'  '||lname from users where users.id = #{user_id}) as username,
        now() as print_at
      from
        expenses
        left join products on products.id = expenses.product_id
      where
        expenses.at_date = '#{at_date}' and
        products.config = '4'
      group by
        product_name,
        products_id,
        username,
        print_at
      order by products_id
      )
      order by seq
      "

      TrialBalance.delete_all()
      rs = Expense.find_by_sql(sql)
      rs.each {|u|
        TrialBalance.create({
          seq: u.seq,
          product_name: u.product_name,
          products_id: u.products_id,
          debit: u.debit,
          credit: u.credit,
          username: u.username,
        })
      }

      data = JasperReport.run_report({
        report: "hotel/report/trial_balance",
        format: "pdf",
        params: {
          at_date: at_date,
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
          start_date: date_datesql(params[:search][:start_date]),
          end_date: date_datesql(params[:search][:end_date]),
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
          start_date: date_datesql(params[:search][:start_date]).to_i*1000,
          end_date: date_datesql(params[:search][:end_date]).to_i*1000,
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
          start_date: date_datesql(params[:search][:start_date]).to_i*1000,
          end_date: date_datesql(params[:search][:end_date]).to_i*1000,
          user_id: current_user.id
        }
      })     
      mime = Mime::Type.lookup_by_extension("pdf").to_s
      send_data(data, :type => mime, :disposition => "inline"  ) 
    end      
  end
end
