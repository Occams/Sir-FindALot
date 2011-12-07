class Admin::ParkinglotsController < ApplicationController
  before_filter :authorize
  
  def create
    unless params[:parkinglot].kind_of?(Array)
      params[:parkinglot] = [params[:parkinglot]]
    end
    
    params[:parkinglot].each do |lot|
      @parkingplane.lots << Parkinglot.create(lot)
    end
    @params = params
    
    redirect_to edit_admin_parkingramp_parkingplane_url(@parkingramp, @parkingplane)
  end
  
  def update
    if params[:parkinglot].kind_of?(Array)
      params[:parkinglot].each do |lot|
        l = @parkingplane.lots.find(lot[:id])
        l.update_attributes(lot) if lot
      end
    else
      lot = @parkingplane.lots.find(params[:id])
      lot.update_attributes(params[:parkinglot]) if lot
    end
    
    @params = params
    
    respond_to do |format|
      format.html { redirect_to edit_admin_parkingramp_parkingplane_url(@parkingramp, @parkingplane), notice: 'Parkingplane was successfully updated.' }
      format.json { head :ok }
    end
  end
  
  def destroy
    @parkingplane.lots.find(params[:id].to_s.split(",").map(&:to_i)).map(&:destroy)
    
    respond_to do |format|
      format.html { redirect_to edit_admin_parkingramp_parkingplane_url(@parkingramp, @parkingplane), notice: 'Parkinglots were deleted.' }
      format.json { head :ok }
    end
  end

private
  def authorize
    @parkingramp = Parkingramp.find(:first, :conditions => {:id => params[:parkingramp_id], :operator_id => current_operator.id})
    raise ActiveRecord::RecordNotFound if @parkingramp.nil?
    
    @parkingplane = @parkingramp.parkingplanes.find(params[:parkingplane_id])
    raise ActiveRecord::RecordNotFound if @parkingplane.nil?
  end
end
