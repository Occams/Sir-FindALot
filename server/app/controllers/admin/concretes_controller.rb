class Admin::ConcretesController < ApplicationController
  before_filter :authorize
  
  def create
    unless params[:concrete].kind_of?(Array)
      params[:concrete] = [params[:concrete]]
    end
    
    params[:concrete].each do |concrete|
      @parkingplane.concretes << Concrete.create(concrete)
    end
    @params = params
    
    redirect_to edit_admin_parkingramp_parkingplane_url(@parkingramp, @parkingplane)
  end
  
  def update
    if params[:concrete].kind_of?(Array)
      params[:concrete].each do |concrete|
        l = @parkingplane.concretes.find(concrete[:id])
        l.update_attributes(concrete) if concrete
      end
    else
      concrete = @parkingplane.concretes.find(params[:id])
      concrete.update_attributes(params[:concrete]) if concrete
    end
    
    @params = params
    
    respond_to do |format|
      format.html { redirect_to edit_admin_parkingramp_parkingplane_url(@parkingramp, @parkingplane), notice: 'Parkingplane was successfully updated.' }
      format.json { head :ok }
    end
  end
  
  def destroy
    @parkingplane.concretes.find(params[:id].to_s.split(",").map(&:to_i)).map(&:destroy)
    
    respond_to do |format|
      format.html { redirect_to edit_admin_parkingramp_parkingplane_url(@parkingramp, @parkingplane), notice: 'Concretes were deleted.' }
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
