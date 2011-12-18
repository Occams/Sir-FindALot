class SearchesController < ApplicationController
  protect_from_forgery :except => "create"

  def create
    setAccessControl
    @parkingramps = Parkingramp.all
    
    respond_to do |format|
      format.html {}
      format.json { render :text => @parkingramps.to_json }
    end
  end
end
