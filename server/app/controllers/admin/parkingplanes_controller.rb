class Admin::ParkingplanesController < Admin::ApplicationController
  before_filter :load_ramp

  # GET /admin/parkingplanes/new
  # GET /admin/parkingplanes/new.json
  def new
    @parkingplane = Parkingplane.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @parkingplane }
    end
  end

  # GET /admin/parkingplanes/1/edit
  def edit
    @parkingplane = Parkingplane.find(params[:id])
  end

  # POST /admin/parkingplanes
  # POST /admin/parkingplanes.json
  def create
    @parkingplane = Parkingplane.new(params[:parkingplane])
    @parkingplane.parkingramp_id = @parkingramp.id

    respond_to do |format|
      if @parkingplane.save
        format.html { redirect_to edit_admin_parkingramp_parkingplane_url(@parkingramp, @parkingplane), notice: 'Parkingplane was successfully created.' }
        format.json { render json: @parkingplane, status: :created, location: @parkingplane }
      else
        format.html { render action: "new" }
        format.json { render json: @parkingplane.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/parkingplanes/1
  # PUT /admin/parkingplanes/1.json
  def update
    @parkingplane = Parkingplane.find(params[:id])

    respond_to do |format|
      if @parkingplane.update_attributes(params[:parkingplane])
        format.html { redirect_to edit_admin_parkingramp_parkingplane_url(@parkingramp, @parkingplane), notice: 'Parkingplane was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @parkingplane.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/parkingplanes/1
  # DELETE /admin/parkingplanes/1.json
  def destroy
    @parkingplane = Parkingplane.find(params[:id])
    @parkingplane.destroy

    respond_to do |format|
      format.html { redirect_to admin_parkingramps_url }
      format.json { head :ok }
    end
  end
  
private
  def load_ramp
    @parkingramp = Parkingramp.find(:first, :conditions => {:id => params[:parkingramp_id], :operator_id => current_operator.id})
    raise ActiveRecord::RecordNotFound if @parkingramp.nil?
  end
  
  def operator_panel_links
    ls = super.push [@parkingramp.name, edit_admin_parkingramp_url(@parkingramp)]
    ls.push (@parkingplane.new_record? ? Parkingplane.t(:new) : @parkingplane.name)
  end
end
