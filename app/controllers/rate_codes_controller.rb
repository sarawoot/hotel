class RateCodesController < ApplicationController
  set_tab :admin
  # GET /rate_codes
  # GET /rate_codes.json
  def index
    search = ""
    if params[:id].to_s != "" and params[:room_type_id].to_s != ""
      search = "rate_codes.id = #{params[:id]} and rate_code_details.room_type_id = #{params[:room_type_id]} "
    end
    
    @rate_codes = RateCode.where(hotel_src_id: current_user.hotel_src_id).order(:name).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: RateCodeDetail.joins(:rate_code).where(search) }
    end
  end

  # GET /rate_codes/1
  # GET /rate_codes/1.json
  def show
    @rate_code = RateCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rate_code }
    end
  end

  # GET /rate_codes/new
  # GET /rate_codes/new.json
  def new
    @rate_code = RateCode.new
    #1.times { @rate_code.rate_code_details.build }
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rate_code }
    end
  end

  # GET /rate_codes/1/edit
  def edit
    @rate_code = RateCode.find(params[:id])
  end

  # POST /rate_codes
  # POST /rate_codes.json
  def create
    @rate_code = RateCode.new(params[:rate_code])

    respond_to do |format|
      if @rate_code.save
        format.html { redirect_to rate_codes_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @rate_code, status: :created, location: @rate_code }
      else
        format.html { render action: "new" }
        format.json { render json: @rate_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rate_codes/1
  # PUT /rate_codes/1.json
  def update
    @rate_code = RateCode.find(params[:id])

    respond_to do |format|
      if @rate_code.update_attributes(params[:rate_code])
        format.html { redirect_to rate_codes_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rate_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rate_codes/1
  # DELETE /rate_codes/1.json
  def destroy
    @rate_code = RateCode.find(params[:id])
    @rate_code.destroy

    respond_to do |format|
      format.html { redirect_to rate_codes_url }
      format.json { head :no_content }
    end
  end
end
