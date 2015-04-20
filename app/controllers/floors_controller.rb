class FloorsController < ApplicationController
  set_tab :admin
  # GET /floors
  # GET /floors.json
  def index
    @floors = Floor.where(hotel_src_id: current_user.hotel_src_id).order(:seq).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @floors }
    end
  end

  # GET /floors/1
  # GET /floors/1.json
  def show
    @floor = Floor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @floor }
    end
  end

  # GET /floors/new
  # GET /floors/new.json
  def new
    @floor = Floor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @floor }
    end
  end

  # GET /floors/1/edit
  def edit
    @floor = Floor.find(params[:id])
  end

  # POST /floors
  # POST /floors.json
  def create
    @floor = Floor.new(params[:floor])

    respond_to do |format|
      if @floor.save
        format.html { redirect_to floors_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @floor, status: :created, location: @floor }
      else
        format.html { render action: "new" }
        format.json { render json: @floor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /floors/1
  # PUT /floors/1.json
  def update
    @floor = Floor.find(params[:id])

    respond_to do |format|
      if @floor.update_attributes(params[:floor])
        format.html { redirect_to floors_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @floor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /floors/1
  # DELETE /floors/1.json
  def destroy
    @floor = Floor.find(params[:id])
    @floor.destroy

    respond_to do |format|
      format.html { redirect_to floors_url }
      format.json { head :no_content }
    end
  end
end
