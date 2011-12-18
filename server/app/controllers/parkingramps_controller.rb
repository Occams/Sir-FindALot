class ParkingrampsController < ApplicationController
  def show
    setAccessControl
    @parkingramp = Parkingramp.find(params[:id])
  end
end
