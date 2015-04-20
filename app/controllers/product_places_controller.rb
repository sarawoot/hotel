class ProductPlacesController < ApplicationController
  # GET /product_places
  # GET /product_places.json
  set_tab :admin
  def index
    @product_places = ProductPlace.where(hotel_src_id: current_user.hotel_src_id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @product_places }
    end
  end

  # GET /product_places/1
  # GET /product_places/1.json
  def show
    @product_place = ProductPlace.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_place }
    end
  end

  # GET /product_places/new
  # GET /product_places/new.json
  def new
    @product_place = ProductPlace.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_place }
    end
  end

  # GET /product_places/1/edit
  def edit
    @product_place = ProductPlace.find(params[:id])
  end

  # POST /product_places
  # POST /product_places.json
  def create
    @product_place = ProductPlace.new(params[:product_place])

    respond_to do |format|
      if @product_place.save
        format.html { redirect_to product_places_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @product_place, status: :created, location: @product_place }
      else
        format.html { render action: "new" }
        format.json { render json: @product_place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /product_places/1
  # PUT /product_places/1.json
  def update
    @product_place = ProductPlace.find(params[:id])

    respond_to do |format|
      if @product_place.update_attributes(params[:product_place])
        format.html { redirect_to product_places_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product_place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_places/1
  # DELETE /product_places/1.json
  def destroy
    @product_place = ProductPlace.find(params[:id])
    @product_place.destroy

    respond_to do |format|
      format.html { redirect_to product_places_url }
      format.json { head :no_content }
    end
  end
end
