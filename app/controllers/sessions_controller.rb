class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      
      rs = HistoryShift.new
      rs.shift_id = get_shift
      rs.user_id = user.id
      rs.login_at = Time.now
      User.hotel_src = user.hotel_src_id
      rs.save
      
      hotel = begin
        HotelSrc.find(user.hotel_src_id).name
      rescue
        ""
      end

      redirect_to_target_or_default root_url, :notice => "Logged in successfully."
    else
      flash.now[:alert] = "Invalid login or password."
      render :action => 'new'
    end
  end

  def destroy
    id  = HistoryShift.select("max(id) as id").where(user_id: current_user.id).first
    id = id.id
    rs = HistoryShift.find(id)
    rs.logout_at = Time.now
    rs.save
    
    session[:user_id] = nil
    redirect_to root_url, :notice => "You have been logged out."
  end
end
