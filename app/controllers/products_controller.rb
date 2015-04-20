class ProductsController < ApplicationController
  # GET /products
  # GET /products.json
  set_tab :admin
  def index
    search = []
    begin
      if params[:search].to_s != ""
        search.push("product_place_id = #{params[:search][:product_place_id]}") if params[:search][:product_place_id].to_i != 0 
        search.push("config != '' ") if params[:search][:product_place_id].to_s == '0' 
      end
    rescue
      ""
    end
    @products = Product.where(search.join(" and ")).order(:product_place_id).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        format.html { redirect_to products_path, notice: "#{I18n.t "html.save_success"}" }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to products_path, notice: "#{I18n.t "html.update_success"}" }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end
  
  def product_combo
    rs = Product.where(used: '1', hotel_src_id: current_user.hotel_src_id)
    datas = []
    datas = rs.collect{|u|{
      id: u.id,
      name: u.product_name
    }}
    respond_to do |format|
      format.json { render json: datas }
    end    
  end
end
