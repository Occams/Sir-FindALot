class ParkingrampsController < ApplicationController
  def show
    @parkingramp = Parkingramp.find(params[:id])
    
    respond_to do |format|
      format.html {}
      format.json {@parkingramp.to_json(:include => {:parkingplanes => {:include => :lots}})}
    end
  end
end
