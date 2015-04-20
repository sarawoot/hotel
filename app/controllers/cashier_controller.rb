class CashierController < ApplicationController
  set_tab :cashier
  ##################################################
  #
  #
  #index for check out show only check in, check out
  #
  #
  ##################################################
  def check_out_index
    search = []
    if params[:search].to_s != ""
      if params[:search][:start_at].to_s != "" and  params[:search][:end_at].to_s != ""
        search.push("date(input_types.dpt_at) between '#{date_datesql(params[:search][:start_at])}' and '#{date_datesql(params[:search][:end_at])}' ")
      end
      search.push("input_types.contact_id = #{params[:search][:contact_id]}") if params[:search][:contact_id].to_s != ""
      search.push("input_types.ref like '%#{params[:search][:ref]}%'") if params[:search][:ref].to_s != ""
      search.push("input_types.stay_status = '#{params[:search][:stay_status]}'") if params[:search][:stay_status].to_s != ""

      if params[:search][:room_id].to_s != ""
        search.push("input_types.id in (select room_lists.input_type_id from room_lists where input_types.id = room_lists.input_type_id and room_lists.room_id = #{params[:search][:room_id]})") 
      end
    end
    confirm_id = RsvtStatus.where(status: '1').first.id
    search.push("input_types.rsvt_status_id = #{confirm_id}")# ยืนยันการจอง
    search.push("( input_types.stay_status =  '1' or input_types.stay_status =  '0' )") #กำลังอยู่ในสถานะ check in,out
    
    search.push("input_types.hotel_src_id = #{current_user.hotel_src_id}")#โรงแรมที่ Login
    @input_types = InputType.where(search.join(" and ")).order(:arvl_at).page(params[:page])
  end
  
  ##################################################
  #
  #
  # form check
  #
  #
  ##################################################
  def check_out
    @input_type = InputType.find(params[:input_type_id])
  end
  ##################################################
  #
  #
  # check out for room is select from user
  #
  #
  ##################################################
  def check_out_room
    #input_types,     stay_status 1(in), 0(out)
    #room_lists,      status 3(in), 4(out) จะ update ตามค่าที่ส่งมาจาก checkbox
    #stay_lists,      status 1(in), 0(out)
    #rooms,           status 2(vacant_dirty)
    @input_type = InputType.find(params[:id])    
    field_name = @input_type.type.underscore
    @input_type.stay_status = '0' #check out
    begin
      InputType.transaction do
        params[:"#{field_name}"][:room_lists_attributes].each {|rl|
          if rl[1][:status].to_s == '3' #check in
            @input_type.stay_status = '1' #check in
          end
          if rl[1][:status].to_s == '4' #check out
            StayList.update_all("status = '0'", "room_list_id = #{rl[1][:id]}")
            #
            room_list = RoomList.find(rl[1][:id])
            if room_list.room_id.to_s != ""
              room = Room.find(room_list.room_id)
              room.status = '2'#(vacant_dirty)
              room.save
            end
            #
            rl[1][:dpt_by] = current_user.id
            rl[1][:dpt_at] = Time.now
          end
        }# end each |rl|
        
        if @input_type.stay_status == '0' #check out
          @input_type.dpt_at = Time.now
        end 
        
        @input_type.update_attributes(params[:"#{field_name}"])
      end # end transaction
      redirect_to check_out_path(input_type_id: params[:id]), notice: "#{I18n.t "html.save_success"}"
    rescue
      redirect_to check_out_path(input_type_id: params[:id]), alert: "#{I18n.t "html.please_do_again"}"
    end
  end
  ##################################################
  #
  #
  # action payment
  #
  #
  ##################################################
  def check_out_payment
  end
  ##################################################
  #
  #
  #gen folio return pdf
  #
  #
  ##################################################
  def check_out_folio
    sql = "
      select 
        expenses.at_date,
        room_lists.room_id,
        sum(expenses.price) as price
      from 
        expenses
        left join products on products.id = expenses.product_id
        left join room_lists on room_lists.id = expenses.room_list_id
        left join rooms on rooms.id = room_lists.room_id 
      where 
        expenses.folio_id = #{params[:folio_id]} and products.config in ('1','3')
      group by 
        expenses.at_date,
        room_lists.room_id
      order by
        room_lists.room_id
    "
    room_charge = Expense.find_by_sql(sql)
    
    sql = "
      select 
        expenses.at_date,
        room_lists.room_id,
        expenses.price,
        products.name as product_name,
        product_places.name as product_place,
        expenses.ref
      from 
        expenses
        left join products on products.id = expenses.product_id
        left join product_places on product_places.id = products.product_place_id
        left join room_lists on room_lists.id = expenses.room_list_id
        left join rooms on rooms.id = room_lists.room_id 
      where 
        expenses.folio_id = #{params[:folio_id]} and products.config = '4'
    "
    payment = Expense.find_by_sql(sql)
    
    sql = "
      select 
        expenses.at_date,
        room_lists.room_id,
        expenses.price,
        products.name as product_name,
        product_places.name as product_place,
        expenses.ref
      from 
        expenses
        left join products on products.id = expenses.product_id
        left join product_places on product_places.id = products.product_place_id
        left join room_lists on room_lists.id = expenses.room_list_id
        left join rooms on rooms.id = room_lists.room_id 
      where 
        expenses.folio_id = #{params[:folio_id]} and products.config not in ('1','3','4')
    "
    transaction = Expense.find_by_sql(sql)
    
    folio = Folio.find(params[:folio_id])
    input_type = InputType.find(folio.input_type_id)
    contact = input_type.contact
    contact_name = begin contact.name rescue "" end
    contact_address = begin contact.address rescue "" end
    
    payment.each {|u|
      product_name = u.product_name
      product_name = "#{u.product_place}/#{u.product_name}" if u.product_place.to_s != ""
      tmp = FolioTmp.new
      tmp.folio_id = params[:folio_id]
      tmp.folio_no = folio.folio_no
      tmp.contact_name =  contact_name
      tmp.contact_address = contact_address
      tmp.arvl_at = input_type.arvl_at
      tmp.dpt_at = input_type.dpt_at
      tmp.at_date = u.at_date
      tmp.room_no = begin Room.find(u.room_id).room_no rescue "" end
      tmp.des = product_name
      tmp.debit = nil
      tmp.credit = u.price.abs
      tmp.ref = u.ref
      tmp.username = current_user.full_name
      tmp.save
    }
    room_charge.each {|u|
      tmp = FolioTmp.new
      tmp.folio_id = params[:folio_id]
      tmp.folio_no = folio.folio_no
      tmp.contact_name =  contact_name
      tmp.contact_address = contact_address
      tmp.arvl_at = input_type.arvl_at
      tmp.dpt_at = input_type.dpt_at
      tmp.at_date = u.at_date
      tmp.room_no = begin Room.find(u.room_id).room_no rescue "" end
      tmp.des = "ROOM CHARGE AUTO"
      tmp.debit = u.price
      tmp.credit = nil
      tmp.ref = ""
      tmp.username = current_user.full_name
      tmp.save
    }
    transaction.each {|u|
      product_name = u.product_name
      product_name = "#{u.product_place}/#{u.product_name}" if u.product_place.to_s != ""
      tmp = FolioTmp.new
      tmp.folio_id = params[:folio_id]
      tmp.folio_no = folio.folio_no
      tmp.contact_name =  contact_name
      tmp.contact_address = contact_address
      tmp.arvl_at = input_type.arvl_at
      tmp.dpt_at = input_type.dpt_at
      tmp.at_date = u.at_date
      tmp.room_no = begin Room.find(u.room_id).room_no rescue "" end
      tmp.des = product_name
      tmp.debit = u.price
      tmp.credit = nil
      tmp.ref = u.ref
      tmp.username = current_user.full_name
      tmp.save
    }
    
    data = JasperReport.run_report({
      report: "reports/hotel/folio",
      format: "pdf",
      params: {folio_id: params[:folio_id]}
    })
    mime = Mime::Type.lookup_by_extension("pdf").to_s
    send_data(data, :type => mime, :disposition => "inline"  )
    
    FolioTmp.delete_all("folio_id = #{params[:folio_id]}")
  end
  
  ##################################################
  #
  #
  #get data for tree grid. it return json
  #
  #
  ##################################################
  def get_folio
    amount = 0.0
    paid = 0.0
    remain = 0.0
    datas = {rows: [],footer:[]}
    folios = Folio.where(input_type_id: params[:input_type_id]).order(:id)
    i = 0
    i_tmp = 0
    folios.each {|f|
      i += 1
      i_tmp = i
      folio_name = f.folio_no
      folio_name += "(#{f.remark})" if f.remark.to_s != ""
      datas[:rows].push({
        id: i,
        folio_no: folio_name,
        leaf: false,
        folio_id: f.id,
      })
      exp = Expense.where(folio_id: f.id).order(:id)
      exp.each {|e|
        product_tmp = e.product
        if product_tmp.config.to_s != "4"
          amount += e.price.to_f
        else
          paid += e.price
        end
        i += 1
        datas[:rows].push({
          id: i,
          folio_no: "Detail",
          product_id: e.product_id, 
          product_name: product_tmp.product_name, 
          at_date: date_dateform(e.at_date),
          per_unit: e.per_unit,
          vol: e.vol,
          price: e.price,
          ref: e.ref.to_s,
          _parentId: i_tmp,
          leaf: true,
          folio_id: f.id,
          expense_id: e.id,
          room: begin e.room_list.room.room_no rescue "" end,
          room_list_id: e.room_list_id,
          input_type_id: e.input_type_id
        })
      }
    }
    
    datas[:footer].push({
      folio_no: "<b>#{t("html.amount")}</b>",
      price: "<b>#{"%.2f" % (amount)}</b>",
      iconCls: "icon-sum"
    })
    
    datas[:footer].push({
      folio_no: "<b>#{t("html.paid")}</b>",
      price: "<b>#{"%.2f" % (paid)}</b>",
      iconCls: "icon-sum"
    })
    
    datas[:footer].push({
      folio_no: "<b>#{t("html.remain")}</b>",
      price: "<b>#{"%.2f" % (amount + paid)}</b>",
      iconCls: "icon-sum"
    })
        
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: datas }
    end

  end
  
  ##################################################
  #
  #
  # create new folio for treegrid. return json success: true or false
  #
  #
  ##################################################
  def create_folio
    rs = Folio.new
    rs.input_type_id = params[:input_type_id]
    #rs.folio_no = gen_folio_no
    rs.remark = params[:remark]
    if rs.save
      respond_to do |format|
        format.json { render json: {success: true} }
      end
    else
      respond_to do |format|
        format.json { render json: {success: false} }
      end
    end
  end
  ##################################################
  #
  #
  # add charge to folio master
  #
  #
  ##################################################
  def add_charge
    #if params[:charge][:room_list_id].to_s == ""
    #  if params[:charge][:product_id].to_s != ""
    #    pd_tmp = Product.find(params[:charge][:product_id]).config
    #    if pd_tmp != '4' # not payment
    #      respond_to do |format|
    #        format.json { render json: {success: false} }
    #      end
    #      return            
    #    end
    #  else
    #    respond_to do |format|
    #      format.json { render json: {success: false} }
    #    end
    #    return         
    #  end
    #end
    
    if params[:charge][:product_id].to_s == ""
      respond_to do |format|
        format.json { render json: {success: false} }
      end
      return
    end
    
    folio = Folio.where(input_type_id: params[:charge][:input_type_id]).order(:id).first    
    expense = Expense.new(params[:charge])
    expense.folio_id = folio.id
    if expense.save
      respond_to do |format|
        format.json { render json: {success: true} }
      end
    else
      respond_to do |format|
        format.json { render json: {success: false} }
      end
    end
  end
  ##################################################
  #
  #
  # edit charge to folio master
  #
  #
  ##################################################
  def edit_charge
    
    #if params[:echarge][:room_list_id].to_s == ""
    #  if params[:echarge][:product_id].to_s != ""
    #    pd_tmp = Product.find(params[:echarge][:product_id]).config
    #    if pd_tmp != '4' # not payment
    #      respond_to do |format|
    #        format.json { render json: {success: false} }
    #      end
    #      return            
    #    end
    #  else
    #    respond_to do |format|
    #      format.json { render json: {success: false} }
    #    end
    #    return         
    #  end
    #end
    
    
    expense = Expense.find(params[:expense_id])
    if expense.update_attributes(params[:echarge])
      respond_to do |format|
        format.json { render json: {success: true} }
      end
    else
      respond_to do |format|
        format.json { render json: {success: false} }
      end
    end
  end
  ##################################################
  #
  #
  # delete charge to folio master
  #
  #
  ##################################################  
  def delete_charge
    expense = Expense.find(params[:expense_id])
    if expense.destroy
      respond_to do |format|
        format.json { render json: {success: true} }
      end
    else
      respond_to do |format|
        format.json { render json: {success: false} }
      end
    end
  end
  ##################################################
  #
  #
  # get folio for option select
  #
  #
  ##################################################
  
  def option_folio
    @folios = Folio.where(input_type_id: params[:input_type_id])
  end
  
  ##################################################
  #
  #
  # move charge to new folio
  #
  #
  ##################################################
  def move_folio
    begin
      Expense.transaction do
        params[:data].each {|data|
          folio_id = data[1][:folio_id]
          expense_id = []
          if data[1][:children].to_s != ""
            data[1][:children].each {|child|
              expense_id.push(child[1][:expense_id])
            }
            Expense.update_all({folio_id: folio_id},{id: expense_id})
          end
        }
      end
      respond_to do |format|
        format.json { render json: {success: true} }
      end
    rescue
      respond_to do |format|
        format.json { render json: {success: false} }
      end      
    end
  end  
  
  ##################################################
  #
  #
  # other charge
  #
  #
  ##################################################
  def other_charge
    search = []
    #search.push("input_type_id is null")
    if params[:search].to_s != ""
      if params[:search][:start_at].to_s != "" and params[:search][:end_at].to_s != ""
        search.push("date(created_at) between '#{date_datesql(params[:search][:start_at])}' and '#{date_datesql(params[:search][:end_at])}'")      
      end
      search.push("remark like '%#{params[:search][:remark]}%'") if params[:search][:remark].to_s != ""
      search.push("folio_no like '%#{params[:search][:folio]}%'") if params[:search][:folio].to_s != ""
      
      search.push("
      COALESCE((select sum(expenses.price) from expenses, products where expenses.folio_id = folios.id and expenses.product_id = products.id and products.config != '4'),0) + 
	COALESCE((select sum(expenses.price) from expenses, products where expenses.folio_id = folios.id and expenses.product_id = products.id and products.config = '4'),0) != 0
      ") if params[:search][:debtor].to_s == "2"
      
      
    end
    
    @folios = Folio.select("*").where(search.join(" and ")).order("created_at desc").page(params[:page])
  end
  
  def new_other_charge
    @folio = Folio.new
  end

  def create_other_charge
    @folio = Folio.new(params[:folio])
    respond_to do |format|
      if @folio.save
        format.html { redirect_to other_charge_path(search: {start_at: date_dateform(Time.now),end_at: date_dateform(Time.now) }), notice: "#{I18n.t "html.save_success"}" }
      else
        format.html { render action: "new_other_charge" }
      end
    end
  end
  
  def edit_other_charge
    @folio = Folio.find(params[:id])
  end
  
  def update_other_charge
    @folio = Folio.find(params[:id])
    respond_to do |format|
      if @folio.update_attributes(params[:folio])
        format.html { redirect_to other_charge_path(search: {start_at: date_dateform(Time.now),end_at: date_dateform(Time.now) }), notice: "#{I18n.t "html.save_success"}" }
      else
        format.html { render action: "edit_other_charge" }
      end
    end
  end
  
  def move_room
    InputType.transaction do
      input_type = InputType.find(params[:move][:input_type_id])
      room_list = RoomList.find(params[:move][:room_old_id])
      
      
      #status room old is vacant dirty
      room_old = Room.find(room_list.room_id)
      room_old.status = 2
      room_old.save
      
      #status room new is occupied clean
      room_new = Room.find(params[:move][:room_new_id])
      room_new.status = 4
      room_new.save
      
      #update room_lists
      room_list.room_id = params[:move][:room_new_id]
      room_list.room_rate = params[:move][:room_rate]
      room_list.save
      
      #update stay_lists
      ext_rate = params[:move][:ext_bed_rate]
      ext_rate = "null" if params[:move][:ext_bed_rate].to_s == ""
      StayList.update_all("abf_rate = #{params[:move][:abf_rate]},ext_bed_rate = #{ext_rate}",
                          "room_list_id = #{params[:move][:room_old_id]}")
      #log 
      log = LogMoveRoom.new
      log.input_type_id = params[:move][:input_type_id]
      log.room_list_id = params[:move][:room_old_id]
      log.room_old_id = room_old.id
      log.room_new_id = room_new.id
      log.user_id = current_user.id
      log.remark = params[:move][:remark]
      log.save
      
      
    end
    respond_to do |format|
      format.json { render json: {success: true} }
    end
  rescue
    respond_to do |format|
      format.json { render json: {success: false} }
    end
  end  
end
