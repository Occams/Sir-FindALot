class Admin::ParkingrampsController < Admin::ApplicationController
  before_filter :operator_scope

  # GET /admin/parkingramps
  # GET /admin/parkingramps.json
  def index
    @parkingramps = @Parkingramp.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @parkingramps }
    end
  end

  # GET /admin/parkingramps/new
  # GET /admin/parkingramps/new.json
  def new
    @parkingramp = @Parkingramp.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @parkingramp }
    end
  end

  # GET /admin/parkingramps/1/edit
  def edit
    @parkingramp = @Parkingramp.find(params[:id])
  end

  # POST /admin/parkingramps
  # POST /admin/parkingramps.json
  def create
    @parkingramp = @Parkingramp.new(params[:parkingramp])
    @parkingramp.operator = current_operator

    respond_to do |format|
      if @parkingramp.save
        format.html { redirect_to admin_parkingramps_url, notice: 'Parkingramp was successfully created.' }
        format.json { render json: @parkingramp, status: :created, location: @parkingramp }
      else
        format.html { render action: "new" }
        format.json { render json: @parkingramp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/parkingramps/1
  # PUT /admin/parkingramps/1.json
  def update
    @parkingramp = @Parkingramp.find(params[:id])

    respond_to do |format|
      if @parkingramp.operator_id == current_operator.id &&
         @parkingramp.update_attributes(params[:parkingramp])
        format.html { redirect_to admin_parkingramps_url, notice: 'Parkingramp was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @parkingramp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/parkingramps/1
  # DELETE /admin/parkingramps/1.json
  def destroy
    @parkingramp = @Parkingramp.find(params[:id])
    @parkingramp.destroy

    respond_to do |format|
      format.html { redirect_to admin_parkingramps_url }
      format.json { head :ok }
    end
  end
  
private
  def operator_scope
    @Parkingramp = Parkingramp.scoped.where("operator_id" => current_operator.id)
  end
  
  def operator_panel_links
    ls =  super.push [Parkingramp.t(:plural), admin_parkingramps_url]
    if params[:action] == 'index'
      ls.push Parkingramp.t(:plural)
    else
      ls.push (@parkingramp.new_record? ? Parkingramp.t(:new) : @parkingramp.name)
    end
  end
end
