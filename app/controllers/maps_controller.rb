class MapsController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  
  def new
    @map = Map.new
  end
  
  def create
    map = current_user.new_map(map_params)
    map.save
    track_activity(map)

    redirect_to map_path(map)
  end

  def show
    @map = Map.find(params[:id])
    if @map.publicly_available? || user_signed_in?
      render :show
    else
      redirect_to root_path
    end
  end

  def send_link_to_friend
    SendLink.share_link(current_user, params[:friend_email]).deliver_now
    redirect_to map_path(params[:map_id])
  end

  def edit
    @map = current_user.maps.find(params[:id])
  end

  def update
    @map = current_user.maps.find(params[:id])
    @map.update(map_params)
    track_activity(@map)

    respond_to do |format|
      format.html { redirect_to map_path(@map) }
      format.js { }
    end
  end
  
  def destroy
    current_user.delete_map(params[:id])

    redirect_to user_path(current_user)
  end
  
  def geojson
    map = Map.find(params[:map_id])
    @geojson = map.moments.collect do |moment|
      moment.geojson
    end

    render json: @geojson
  end 
  
  private
    def map_params
      params.require(:map).permit(:name, :publicly_available)
    end
end
