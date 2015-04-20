class RsvtTypesController < ApplicationController
  set_tab :admin
  # GET /rsvt_types
  # GET /rsvt_types.json
  def index
    @rsvt_types = RsvtType.where(hotel_src_id: current_user.hotel_src_id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rsvt_types }
    end
  end

  # GET /rsvt_types/1
  # GET /rsvt_types/1.json
  def show
    @rsvt_type = RsvtType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rsvt_type }
    end
  end

  # GET /rsvt_types/new
  # GET /rsvt_types/new.json
  def new
    @rsvt_type = RsvtType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rsvt_type }
    end
  end

  # GET /rsvt_types/1/edit
  def edit
    @rsvt_type = RsvtType.find(params[:id])
  end

  # POST /rsvt_types
  # POST /rsvt_types.json
  def create
    @rsvt_type = RsvtType.new(params[:rsvt_type])

    respond_to do |format|
      if @rsvt_type.save
        format.html { redirect_to rsvt_types_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @rsvt_type, status: :created, location: @rsvt_type }
      else
        format.html { render action: "new" }
        format.json { render json: @rsvt_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rsvt_types/1
  # PUT /rsvt_types/1.json
  def update
    @rsvt_type = RsvtType.find(params[:id])

    respond_to do |format|
      if @rsvt_type.update_attributes(params[:rsvt_type])
        format.html { redirect_to rsvt_types_path, notice: "#{I18n.t "html.update_success"}"}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rsvt_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rsvt_types/1
  # DELETE /rsvt_types/1.json
  def destroy
    @rsvt_type = RsvtType.find(params[:id])
    @rsvt_type.destroy

    respond_to do |format|
      format.html { redirect_to rsvt_types_url }
      format.json { head :no_content }
    end
  end
end
