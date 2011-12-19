class Api::ParkinglotsController < ApplicationController
  before_filter :authenticate_operator!

  def show
    lot = Parkinglot.find(params[:id]) 
    
    if lot.parkingplane.parkingramp.operator_id == current_operator.id
      lot.update_attribute(:taken, params[:taken])
    end
    render :nothing => true, :status => 200
  end
end
