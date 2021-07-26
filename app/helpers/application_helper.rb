module ApplicationHelper
  
  def link_to_remove_fields(name, f, options = {})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", options)
  end

  def link_to_add_fields(name, f, association, modal, options = {}, func = "")
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{ association }") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end

    link_to_function(name, "add_fields(this, \"#{ association }\", \"#{ escape_javascript(fields) }\", \"#{modal}\");#{func}", options)
  end
  ###################################################################################
  def link_to_add_tables(name, f, association, table, options = {})
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{ association }") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_tables(this, \"#{ association }\", \"#{ escape_javascript(fields) }\", \"#{table}\")", options)
  end
  
  def link_to_remove_table(name, f, options = {}, func = "")
    f.hidden_field(:_destroy) + link_to_function(name, "remove_table(this);#{func}", options)
  end
  ###################################################################################
  def link_to_add_rooms(name, f, association, div)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to_function(name, "add_rooms(this, \"##{div}\")", class: "add_fields btn btn-primary", data: {id: id, fields: fields.gsub("\n", "")})
  end
  
  def link_to_remove_rooms(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_rooms(this)", class: "add_fields btn btn-danger")
  end
  
  def format_time(t)
    "#{ "%02d" % t.hour}:#{ "%02d" % t.min}"
  rescue
    ""
  end
  
  def arr_lang
    [
      ["#{t("html.english")}","en"],  
      ["#{t("html.thai")}","th"]  
    ]
  end
  def lang(st)
    arr = arr_lang
    arr.rassoc(st.to_s)[0]
  rescue
    ""
  end
  
  def arr_role
    [
      ["#{t("html.admin")}","admin"],  
      ["#{t("html.user")}","user"]  
    ]
  end
  def role(st)
    arr = arr_role
    arr.rassoc(st.to_s)[0]
  rescue
    ""
  end
  
  def arr_used
    [
      ["#{t("html.used1")}","1"],  
      ["#{t("html.used0")}","0"]  
    ]
  end
  def used(st)
    arr = arr_used
    arr.rassoc(st.to_s)[0]
  rescue
    ""
  end
  
  def arr_status_room
    [
      ["#{t("html.vacant_clean")}","1"],#green
      ["#{t("html.vacant_dirty")}","2"], #blue
      ["#{t("html.occupied_clean")}","4"], #pink
      ["#{t("html.occupied_dirty")}","5"], #gray
      ["#{t("html.out_off_order")}","0"] #red
    ]
  end
  def status_room(st)
    arr = arr_status_room
    arr.rassoc(st.to_s)[0]
  rescue
    ""
  end
  

  def arr_status_rsvt#rsvt_statuses, statua
    [
      ["#{t("html.active")}","1"],
      ["#{t("html.in_process")}","2"], 
      ["#{t("html.cancel")}","0"], 
    ]
  end

  def arr_status_room_lists#room_lists, status
    [
      ["#{t("html.reservation")}","1"],
      ["#{t("html.cancel_reservation")}","2"],
      ["#{t("html.check_in")}","3"],
      ["#{t("html.check_out")}","4"],
      ["#{t("html.in_process")}","5"],
      #["#{t("html.cancel")}","6"]
    ]
  end

  def arr_status_stay_lists#stay_lists,status,    input_types,stay_status
    [
      ["#{t("html.check_in")}","1"],
      ["#{t("html.check_out")}","0"],
      ["#{t("html.cancel")}","2"]
    ]
  end
 
  def status_rsvt(st)
    arr = arr_status_rsvt
    arr.rassoc(st.to_s)[0]
  rescue
    ""
  end
  
  def status_room_lists(st)
    arr = arr_status_room_lists
    arr.rassoc(st.to_s)[0]
  rescue
    ""
  end  
  
  def status_stay_lists(st)
    arr = arr_status_stay_lists
    arr.rassoc(st.to_s)[0]
  rescue
    ""
  end
  
  
  def arr_product_category#product, category
    [
      ["#{t("html.product")}","1"],
      ["#{t("html.service")}","2"]
    ]
  end
  
  def product_category(st)
    arr = arr_product_category
    arr.rassoc(st.to_s)[0]
  rescue
    ""
  end
  
  def arr_product_config#product, config
    [
      ["#{t("html.room_rate_auto")}","1"],
      ["#{t("html.ext_bed_rate")}","2"],
      ["#{t("html.abf_rate_include")}","3"],      
      ["#{t("html.payment")}","4"],
      
      
      ["#{t("html.day_use")}","5"],
      ["#{t("html.room_rate")}","6"],#other
      ["#{t("html.abf_rate")}","7"],#other
    ]
  end
  
  def product_config(st)
    arr = arr_product_config
    arr.rassoc(st.to_s)[0]
  rescue
    ""
  end
  

  ########################### Source
  
  def room_src(arr=true)
    src = Room.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.room_no, u.id]} if arr
    src = Room.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  
  def floor_src(arr=true)
    src = Floor.where(used: "1", hotel_src_id: current_user.hotel_src_id).order(:seq).collect{|u| [u.name, u.id]} if arr
    src = Floor.where(used: "1", hotel_src_id: current_user.hotel_src_id).order(:seq) if !arr
    src
  rescue
    []
  end
  
  def agent_src(arr=true)
    src = Agent.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr == true
    src = Agent.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def nation_src(arr=true)
    src = Nation.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr
    src = Nation.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def gst_level_src(arr=true)
    src = GstLevel.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr
    src = GstLevel.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def gst_type_src(arr=true)
    src = GstType.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr
    src = GstType.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def src_gst_src(arr=true)
    src = SrcGst.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr
    src = SrcGst.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def prpt_grp_src(arr=true)
    src = PrptGrp.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr
    src = PrptGrp.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def rsvt_type_src(arr=true)
    src = RsvtType.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr
    src = RsvtType.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def rsvt_status_src(arr=true)
    src = RsvtStatus.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr
    src = RsvtStatus.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def room_type_src(arr=true)
    src = RoomType.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr
    src = RoomType.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def rate_code_src(arr=true)
    src = RateCode.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr
    src = RateCode.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def paid_src(arr=true)
    src = Paid.where(used: "1", hotel_src_id: current_user.hotel_src_id).collect{|u| [u.name,u.id]} if arr
    src = Paid.where(used: "1", hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  def room_list_chk_in_src(arr=true)
    src = RoomList.where(status: '3', hotel_src_id: current_user.hotel_src_id).collect{|u| [begin u.room.room_no rescue "" end,u.id]} if arr
    src = RoomList.select("room_lists.id,rooms.room_no").joins(:room).where(status: '3', hotel_src_id: current_user.hotel_src_id) if !arr
    src
  rescue
    []
  end
  
  
  def contact_chk_in_src(arr=true)
    confirm_id = RsvtStatus.where(status: '1').first.id
    contact_id = "select contact_id from input_types where stay_status = '1'  and rsvt_status_id = #{confirm_id} and hotel_src_id = #{current_user.hotel_src_id}"
    src = Contact.where("id in (#{contact_id})").collect{|u| [begin u.name rescue "" end,u.id]} if arr
    src = Contact.where("id in (#{contact_id})") if !arr
    src
  rescue
    []
  end
  
  def product_all_src(arr=true)
    rs = Product.select("products.id,products.name,product_places.name as place_name")
          .joins("left join product_places on products.product_place_id = product_places.id")
          .where(" products.used = '1' and products.hotel_src_id = #{current_user.hotel_src_id} ").order(:id)
    src = rs.collect{|u| ["#{u.place_name}#{"/" if u.place_name.to_s != ""}#{u.name}",u.id]} if arr
    src = rs if !arr
    src
  rescue
    []
  end
  
  def product_src(arr=true)
    rs = Product.select("products.id,products.name,product_places.name as place_name")
          .joins("left join product_places on products.product_place_id = product_places.id")
          .where(" products.used = '1' and products.hotel_src_id = #{current_user.hotel_src_id} and config not in ('1','2','3','4')").order(:id)
    src = rs.collect{|u| ["#{u.place_name}#{"/" if u.place_name.to_s != ""}#{u.name}",u.id]} if arr
    src = rs if !arr
    src
  rescue
    []
  end
  
  def product_payment_src(arr=true)
    rs = Product.select("products.id,products.name,product_places.name as place_name")
          .joins("left join product_places on products.product_place_id = product_places.id")
          .where(" products.used = '1' and products.hotel_src_id = #{current_user.hotel_src_id} and config = '4' ").order(:id)
    src = rs.collect{|u| ["#{u.place_name}#{"/" if u.place_name.to_s != ""}#{u.name}",u.id]} if arr
    src = rs if !arr
    src
  
  end
  
  
  def product_place_src(arr=true)
    src = ProductPlace.where(" used = '1' and hotel_src_id = #{current_user.hotel_src_id}" ).collect{|u| [u.name,u.id]} if arr
    src = ProductPlace.where(" used = '1' and hotel_src_id = #{current_user.hotel_src_id}") if !arr
    src
  rescue
    []
  end
  
  def shift_src(arr=true)
    rs = Shift.where(used: "1", hotel_src_id: current_user.hotel_src_id)
    src = rs.collect{|u| [u.name,u.id]} if arr
    src = rs if !arr
    src
  rescue
    []
  end
end
