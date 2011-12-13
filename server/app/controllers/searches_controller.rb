class SearchesController < ApplicationController
  def create
    @parkingramps = Parkingramp.all
    
    respond_to do |format|
      format.html {}
      format.json { @parkingramps.to_json }
    end
  end
end
