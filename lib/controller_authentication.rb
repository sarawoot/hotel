# This module is included in your application controller which makes
# several methods available to all controllers and views. Here's a
# common example you might add to your application layout file.
#
#   <% if logged_in? %>
#     Welcome <%= current_user.username %>.
#     <%= link_to "Edit profile", edit_current_user_path %> or
#     <%= link_to "Log out", logout_path %>
#   <% else %>
#     <%= link_to "Sign up", signup_path %> or
#     <%= link_to "log in", login_path %>.
#   <% end %>
#
# You can also restrict unregistered users from accessing a controller using
# a before filter. For example.
#
#   before_filter :login_required, :except => [:index, :show]
module ControllerAuthentication
  def self.included(controller)
    controller.send :helper_method, :current_user, :logged_in?, :redirect_to_target_or_default, :is_admin?, :is_user?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user
  end

  def login_required
    if session[:user_id]
      User.hotel_src = current_user.hotel_src_id
      User.current_user_id = current_user.id
      I18n.locale = current_user.lang
      hotel = begin
        HotelSrc.find(current_user.hotel_src_id).name
      rescue
        ""
      end      
      I18n.backend.store_translations(current_user.lang, {html: {title: "#{hotel}"}}, :escape => false)
    end
    unless logged_in?
      if params[:controller].to_s == "sessions"
        return
      end
      store_target_location
      redirect_to login_url, :alert => "You must first log in or sign up before accessing this page." 
    end
  end

  def redirect_to_target_or_default(default, *args)
    redirect_to(session[:return_to] || default, *args)
    session[:return_to] = nil
  end
  
  def is_admin?
    current_user.roll == "admin"
  end
  
  def is_user?
    current_user.roll == "user"
  end

  private

  def store_target_location
    session[:return_to] = request.url
  end
end
