class RsvtStatusesController < ApplicationController
  set_tab :admin
  # GET /rsvt_statuses
  # GET /rsvt_statuses.json
  def index
    search = ""
    if params[:id].to_s != ""
      search = "id = #{params[:id]}"
    end
    
    @rsvt_statuses = RsvtStatus.where(hotel_src_id: current_user.hotel_src_id).where(search).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rsvt_statuses }
    end
  end

  # GET /rsvt_statuses/1
  # GET /rsvt_statuses/1.json
  def show
    @rsvt_status = RsvtStatus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rsvt_status }
    end
  end

  # GET /rsvt_statuses/new
  # GET /rsvt_statuses/new.json
  def new
    @rsvt_status = RsvtStatus.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rsvt_status }
    end
  end

  # GET /rsvt_statuses/1/edit
  def edit
    @rsvt_status = RsvtStatus.find(params[:id])
  end

  # POST /rsvt_statuses
  # POST /rsvt_statuses.json
  def create
    @rsvt_status = RsvtStatus.new(params[:rsvt_status])

    respond_to do |format|
      if @rsvt_status.save
        format.html { redirect_to rsvt_statuses_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @rsvt_status, status: :created, location: @rsvt_status }
      else
        format.html { render action: "new" }
        format.json { render json: @rsvt_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rsvt_statuses/1
  # PUT /rsvt_statuses/1.json
  def update
    @rsvt_status = RsvtStatus.find(params[:id])

    respond_to do |format|
      if @rsvt_status.update_attributes(params[:rsvt_status])
        format.html { redirect_to rsvt_statuses_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rsvt_status.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rsvt_statuses/1
  # DELETE /rsvt_statuses/1.json
  def destroy
    @rsvt_status = RsvtStatus.find(params[:id])
    @rsvt_status.destroy

    respond_to do |format|
      format.html { redirect_to rsvt_statuses_url }
      format.json { head :no_content }
    end
  end
end
