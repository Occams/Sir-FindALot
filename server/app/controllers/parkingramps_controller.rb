class ParkingrampsController < ApplicationController
  def show
    @parkingramp = Parkingramp.find(params[:id])
  end
end
