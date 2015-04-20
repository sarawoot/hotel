class HomeController < ApplicationController
  
  def index
    search = []
    search.push("rooms.used = '1'")
    begin
      search.push("rooms.status = '#{params[:search][:status]}'") if params[:search][:status].to_s != ""
      search.push("rooms.id = '#{params[:search][:room_id]}'") if params[:search][:room_id].to_s != ""
      search.push("room_type_id = '#{params[:search][:room_type_id]}'") if params[:search][:room_type_id].to_s != ""
      search.push("floor_id = '#{params[:search][:floor_id]}'") if params[:search][:floor_id].to_s != ""
    rescue
      ""
    end
    @rooms = Room.joins(:floor).where(search.join(" and ")).order("floors.seq,rooms.seq").page(params[:page])

    respond_to do |format|
      format.html 
    end
  end

  def edit
    @room = Room.find(params[:id])
  end

  def update
    @room = Room.find(params[:id])

    respond_to do |format|
      if @room.update_attributes(params[:room])
        format.html { redirect_to root_path, notice: "#{I18n.t "html.update_success"}" }
      else
        format.html { render action: "edit" }
      end
    end
  end

end
