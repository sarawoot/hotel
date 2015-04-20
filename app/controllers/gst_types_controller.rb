class GstTypesController < ApplicationController
  set_tab :admin
  # GET /gst_types
  # GET /gst_types.json
  def index
    @gst_types = GstType.where(hotel_src_id: current_user.hotel_src_id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gst_types }
    end
  end

  # GET /gst_types/1
  # GET /gst_types/1.json
  def show
    @gst_type = GstType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gst_type }
    end
  end

  # GET /gst_types/new
  # GET /gst_types/new.json
  def new
    @gst_type = GstType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gst_type }
    end
  end

  # GET /gst_types/1/edit
  def edit
    @gst_type = GstType.find(params[:id])
  end

  # POST /gst_types
  # POST /gst_types.json
  def create
    @gst_type = GstType.new(params[:gst_type])

    respond_to do |format|
      if @gst_type.save
        format.html { redirect_to gst_types_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @gst_type, status: :created, location: @gst_type }
      else
        format.html { render action: "new" }
        format.json { render json: @gst_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gst_types/1
  # PUT /gst_types/1.json
  def update
    @gst_type = GstType.find(params[:id])

    respond_to do |format|
      if @gst_type.update_attributes(params[:gst_type])
        format.html { redirect_to gst_types_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gst_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gst_types/1
  # DELETE /gst_types/1.json
  def destroy
    @gst_type = GstType.find(params[:id])
    @gst_type.destroy

    respond_to do |format|
      format.html { redirect_to gst_types_url }
      format.json { head :no_content }
    end
  end
end
