ACCESS_CONTROLS = {
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Headers" => "X-Requested-With",
    "Access-Control-Max-Age" => "60",
    "Access-Control-Request-Method" => '*' 
}

class ParkingrampsController < ApplicationController
  def show
    @parkingramp = Parkingramp.find(params[:id])
    
    ACCESS_CONTROLS.each do |k,v|
      headers[k] = v
    end
  end
end
