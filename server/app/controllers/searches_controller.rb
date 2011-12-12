class SearchesController < ApplicationController
  def create
    @parkingramps = Parkingramp.all
  end
end
