class SearchesController < ApplicationController
  protect_from_forgery :except => "create"

  def create
    if !params[:search]
      @parkingramps = []
    else
      params[:search] = JSON(params[:search])
      @parkingramps = Parkingramp.rankby(params[:search][:geolocation], params[:search][:needle])
    end
  
    respond_to do |format|
      format.html {}
      format.json { render :text => @parkingramps.to_json }
    end
  end
end
