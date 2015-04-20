class SrcGstsController < ApplicationController
  set_tab :admin
  # GET /src_gsts
  # GET /src_gsts.json
  def index
    @src_gsts = SrcGst.where(hotel_src_id: current_user.hotel_src_id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @src_gsts }
    end
  end

  # GET /src_gsts/1
  # GET /src_gsts/1.json
  def show
    @src_gst = SrcGst.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @src_gst }
    end
  end

  # GET /src_gsts/new
  # GET /src_gsts/new.json
  def new
    @src_gst = SrcGst.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @src_gst }
    end
  end

  # GET /src_gsts/1/edit
  def edit
    @src_gst = SrcGst.find(params[:id])
  end

  # POST /src_gsts
  # POST /src_gsts.json
  def create
    @src_gst = SrcGst.new(params[:src_gst])

    respond_to do |format|
      if @src_gst.save
        format.html { redirect_to src_gsts_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @src_gst, status: :created, location: @src_gst }
      else
        format.html { render action: "new" }
        format.json { render json: @src_gst.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /src_gsts/1
  # PUT /src_gsts/1.json
  def update
    @src_gst = SrcGst.find(params[:id])

    respond_to do |format|
      if @src_gst.update_attributes(params[:src_gst])
        format.html { redirect_to src_gsts_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @src_gst.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /src_gsts/1
  # DELETE /src_gsts/1.json
  def destroy
    @src_gst = SrcGst.find(params[:id])
    @src_gst.destroy

    respond_to do |format|
      format.html { redirect_to src_gsts_url }
      format.json { head :no_content }
    end
  end
end
