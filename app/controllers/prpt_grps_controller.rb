class PrptGrpsController < ApplicationController
  set_tab :admin
  # GET /prpt_grps
  # GET /prpt_grps.json
  def index
    @prpt_grps = PrptGrp.where(hotel_src_id: current_user.hotel_src_id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @prpt_grps }
    end
  end

  # GET /prpt_grps/1
  # GET /prpt_grps/1.json
  def show
    @prpt_grp = PrptGrp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @prpt_grp }
    end
  end

  # GET /prpt_grps/new
  # GET /prpt_grps/new.json
  def new
    @prpt_grp = PrptGrp.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @prpt_grp }
    end
  end

  # GET /prpt_grps/1/edit
  def edit
    @prpt_grp = PrptGrp.find(params[:id])
  end

  # POST /prpt_grps
  # POST /prpt_grps.json
  def create
    @prpt_grp = PrptGrp.new(params[:prpt_grp])

    respond_to do |format|
      if @prpt_grp.save
        format.html { redirect_to prpt_grps_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @prpt_grp, status: :created, location: @prpt_grp }
      else
        format.html { render action: "new" }
        format.json { render json: @prpt_grp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /prpt_grps/1
  # PUT /prpt_grps/1.json
  def update
    @prpt_grp = PrptGrp.find(params[:id])

    respond_to do |format|
      if @prpt_grp.update_attributes(params[:prpt_grp])
        format.html { redirect_to prpt_grps_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @prpt_grp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prpt_grps/1
  # DELETE /prpt_grps/1.json
  def destroy
    @prpt_grp = PrptGrp.find(params[:id])
    @prpt_grp.destroy

    respond_to do |format|
      format.html { redirect_to prpt_grps_url }
      format.json { head :no_content }
    end
  end
end
