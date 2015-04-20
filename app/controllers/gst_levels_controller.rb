class GstLevelsController < ApplicationController
  set_tab :admin
  # GET /gst_levels
  # GET /gst_levels.json
  def index
    @gst_levels = GstLevel.where(hotel_src_id: current_user.hotel_src_id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gst_levels }
    end
  end

  # GET /gst_levels/1
  # GET /gst_levels/1.json
  def show
    @gst_level = GstLevel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gst_level }
    end
  end

  # GET /gst_levels/new
  # GET /gst_levels/new.json
  def new
    @gst_level = GstLevel.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gst_level }
    end
  end

  # GET /gst_levels/1/edit
  def edit
    @gst_level = GstLevel.find(params[:id])
  end

  # POST /gst_levels
  # POST /gst_levels.json
  def create
    @gst_level = GstLevel.new(params[:gst_level])

    respond_to do |format|
      if @gst_level.save
        format.html { redirect_to gst_levels_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @gst_level, status: :created, location: @gst_level }
      else
        format.html { render action: "new" }
        format.json { render json: @gst_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gst_levels/1
  # PUT /gst_levels/1.json
  def update
    @gst_level = GstLevel.find(params[:id])

    respond_to do |format|
      if @gst_level.update_attributes(params[:gst_level])
        format.html { redirect_to gst_levels_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gst_level.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gst_levels/1
  # DELETE /gst_levels/1.json
  def destroy
    @gst_level = GstLevel.find(params[:id])
    @gst_level.destroy

    respond_to do |format|
      format.html { redirect_to gst_levels_url }
      format.json { head :no_content }
    end
  end
end
