class RoomsController < ApplicationController
  set_tab :admin
  # GET /rooms
  # GET /rooms.json
  def index
    
    search = "rooms.hotel_src_id = #{current_user.hotel_src_id}"  
    if params[:room_type_id].to_s != "" and params[:dpt_at].to_s != "" and params[:arvl_at].to_s != ""
      search_tmp = time_overlap("#{datetime_datetimesql(params[:arvl_at])}","#{datetime_datetimesql(params[:dpt_at])}","room_lists.arvl_at","room_lists.dpt_at")
      
      sql = " and rooms.id not in (SELECT rooms.id FROM rooms WHERE rooms.status = '0' and rooms.hotel_src_id = #{current_user.hotel_src_id}" 
      sql += " union SELECT room_lists.room_id as id FROM room_lists WHERE room_lists.status in ('1', '3', '5') and #{search_tmp}  and room_lists.hotel_src_id = #{current_user.hotel_src_id} and room_lists.room_id is not null)
              and rooms.room_type_id = #{params[:room_type_id]}"
      search += sql
      search += " and rooms.room_no like '%#{params[:q]}%'" if params[:q].to_s != ""
      #search += " and rooms.status = '1' "
      search = "(#{search}) or rooms.id = #{params[:id]}" if params[:id].to_s != ""
    end
    begin
      search += " and rooms.floor_id = #{params[:search][:floor_id]}" if params[:search][:floor_id].to_s != ""
    rescue
      ""
    end
    @rooms = Room.joins(:floor).where(search).order("floors.seq,rooms.seq").page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: {data: @rooms.select("rooms.id, rooms.room_no"), total: @rooms.total_count}  }
    end
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
    @room = Room.where(id: params[:id], room_type_id: params[:room_type_id]  ).first
    if @room.nil?
      @room = {}
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @room }
    end
  end

  # GET /rooms/new
  # GET /rooms/new.json
  def new
    @room = Room.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @room }
    end
  end

  # GET /rooms/1/edit
  def edit
    @room = Room.find(params[:id])
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(params[:room])

    respond_to do |format|
      if @room.save
        format.html { redirect_to rooms_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @room, status: :created, location: @room }
      else
        format.html { render action: "new" }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rooms/1
  # PUT /rooms/1.json
  def update
    @room = Room.find(params[:id])

    respond_to do |format|
      if @room.update_attributes(params[:room])
        format.html { redirect_to rooms_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    @room = Room.find(params[:id])
    @room.destroy

    respond_to do |format|
      format.html { redirect_to rooms_url }
      format.json { head :no_content }
    end
  end
end
