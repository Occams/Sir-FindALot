class StatsController < ApplicationController
  before_filter :load_parkingramp

  def show
    @stats = []
    puts params.inspect
  
    if params[:week] && params[:year] && params[:hour]
      @stats = @parkingramp.stats.stats_by_weekday_and_hour params[:year].to_i, params[:week].to_i, params[:hour].to_i
    elsif params[:year] && params[:month] && params[:day]
      @stats = @parkingramp.stats.stats_by_hour params[:year].to_i, params[:month].to_i, params[:day].to_i
    elsif params[:year] && params[:hour]
      @stats = @parkingramp.stats.stats_by_month_and_hour params[:year].to_i, params[:hour].to_i
    end
    
    respond_to do |format|
      format.json
    end
  end
  
private
  def load_parkingramp
    @parkingramp = Parkingramp.find(params[:id])
  end
end
