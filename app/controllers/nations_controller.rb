class NationsController < ApplicationController
  set_tab :admin
  # GET /nations
  # GET /nations.json
  def index
    @nations = Nation.where(hotel_src_id: current_user.hotel_src_id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @nations }
    end
  end

  # GET /nations/1
  # GET /nations/1.json
  def show
    @nation = Nation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @nation }
    end
  end

  # GET /nations/new
  # GET /nations/new.json
  def new
    @nation = Nation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @nation }
    end
  end

  # GET /nations/1/edit
  def edit
    @nation = Nation.find(params[:id])
  end

  # POST /nations
  # POST /nations.json
  def create
    @nation = Nation.new(params[:nation])

    respond_to do |format|
      if @nation.save
        format.html { redirect_to nations_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @nation, status: :created, location: @nation }
      else
        format.html { render action: "new" }
        format.json { render json: @nation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /nations/1
  # PUT /nations/1.json
  def update
    @nation = Nation.find(params[:id])

    respond_to do |format|
      if @nation.update_attributes(params[:nation])
        format.html { redirect_to nations_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @nation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nations/1
  # DELETE /nations/1.json
  def destroy
    @nation = Nation.find(params[:id])
    @nation.destroy

    respond_to do |format|
      format.html { redirect_to nations_url }
      format.json { head :no_content }
    end
  end
end
