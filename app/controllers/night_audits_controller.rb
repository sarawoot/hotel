class NightAuditsController < ApplicationController
  # GET /night_audits
  # GET /night_audits.json
  def index
    search = ""
    if params[:search] != nil
      if params[:search][:start_at].to_s != "" && params[:search][:end_at].to_s != ""
        search = "at_date between '#{datetime_datesql(params[:search][:start_at])}' and '#{datetime_datesql(params[:search][:end_at])}'"
      end
    end

    @night_audits = NightAudit.where(search).order("at_date desc").page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @night_audits }
    end
  end

  # GET /night_audits/1
  # GET /night_audits/1.json
  def show
    @night_audit = NightAudit.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @night_audit }
    end
  end

  # GET /night_audits/new
  # GET /night_audits/new.json
  def new
    @night_audit = NightAudit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @night_audit }
    end
  end

  # GET /night_audits/1/edit
  def edit
    @night_audit = NightAudit.find(params[:id])
  end

  # POST /night_audits
  # POST /night_audits.json
  def create
    if NightAudit.where(at_date: date_datesql(params[:night_audit][:at_date])).count > 0
      redirect_to new_night_audit_path({night_audit: {at_date: params[:night_audit][:at_date]}}), notice: "Already have this item"
      return
    end
    
    NightAuditWorker.perform_async(params[:night_audit][:at_date], current_user.hotel_src_id)
    respond_to do |format|
      format.html { redirect_to night_audits_url }
      format.json { render json: @night_audit }
    end
  end

  # PUT /night_audits/1
  # PUT /night_audits/1.json
  def update
    @night_audit = NightAudit.find(params[:id])

    respond_to do |format|
      if @night_audit.update_attributes(params[:night_audit])
        format.html { redirect_to @night_audit, notice: 'Night audit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @night_audit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /night_audits/1
  # DELETE /night_audits/1.json
  def destroy
    @night_audit = NightAudit.find(params[:id])
    OutStanding.destroy_all(at_date: @night_audit.at_date)
    @night_audit.destroy

    respond_to do |format|
      format.html { redirect_to night_audits_url }
      format.json { head :no_content }
    end
  end
end
