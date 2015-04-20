class RoomTypesController < ApplicationController
  set_tab :admin
  # GET /room_types
  # GET /room_types.json
  def index
    @room_types = RoomType.where(hotel_src_id: current_user.hotel_src_id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @room_types }
    end
  end

  # GET /room_types/1
  # GET /room_types/1.json
  def show
    @room_type = RoomType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @room_type }
    end
  end

  # GET /room_types/new
  # GET /room_types/new.json
  def new
    @room_type = RoomType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @room_type }
    end
  end

  # GET /room_types/1/edit
  def edit
    @room_type = RoomType.find(params[:id])
  end

  # POST /room_types
  # POST /room_types.json
  def create
    @room_type = RoomType.new(params[:room_type])

    respond_to do |format|
      if @room_type.save
        format.html { redirect_to room_types_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @room_type, status: :created, location: @room_type }
      else
        format.html { render action: "new" }
        format.json { render json: @room_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /room_types/1
  # PUT /room_types/1.json
  def update
    @room_type = RoomType.find(params[:id])

    respond_to do |format|
      if @room_type.update_attributes(params[:room_type])
        format.html { redirect_to room_types_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @room_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /room_types/1
  # DELETE /room_types/1.json
  def destroy
    @room_type = RoomType.find(params[:id])
    @room_type.destroy

    respond_to do |format|
      format.html { redirect_to room_types_url }
      format.json { head :no_content }
    end
  end
end
