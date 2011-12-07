class Admin::ApplicationController < ApplicationController
  before_filter :authenticate_operator!
  
private
  def operator_panel_links
    super.push [Parkingramp.t(:plural), admin_parkingramps_url]
  end
end
