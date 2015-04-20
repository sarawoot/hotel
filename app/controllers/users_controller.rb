class UsersController < ApplicationController
  
  set_tab :admin
  
  def index
    @users = User.where(hotel_src_id: current_user.hotel_src_id).page(params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to users_path, :notice => "#{I18n.t "html.save_success"}"
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to users_path, :notice => "#{I18n.t "html.update_success"}"
    else
      render :action => 'edit'
    end
  end
end
