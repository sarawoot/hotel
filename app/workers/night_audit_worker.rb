class NightAuditWorker
  include Sidekiq::Worker
  include DateHelper

  def perform(require_date, hotel_src_id)
    at_date = date_datesql(require_date)

    OutStanding.destroy_all(at_date: at_date)
    NightAudit.destroy_all(at_date: at_date)
    NightAudit.create(at_date: at_date, status: 'pending')
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
          credit: u.credit,
          at_date: at_date
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
          credit: u.credit,
          at_date: at_date
      })
    }
    ##################################
    # ตามที่ยังพักอยู่
    ##################################
    
    rs = InputType.select("distinct input_types.id").joins(:room_lists)
          .where("input_types.hotel_src_id = #{hotel_src_id} and input_types.stay_status = '1' and '#{at_date}' between date(room_lists.arvl_at) and date(room_lists.dpt_at)" )
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
            credit: payment[i][1],
            at_date: at_date
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
          credit: u.credit,
          at_date: at_date
      })
    }
    
    NightAudit.where(at_date: at_date).update_all(status:'done')
  end


  def share_payment(arr, money)
    new_arr = []
    money = money.round(2)
    arr.each {|a|
      a = a.round(2)
      new_money = 0.0
      if a < money or a == money
        new_money = a
      end
      if a > money
        new_money = money
      end
      money = money - new_money
      new_arr.push([a.to_f,new_money])
    }
    if money != 0
      new_money = (money / arr.length).round(2)
      new_arr.each{|a|
        a[1] += new_money
      }
    end
    new_arr
  rescue
    []
  end
end