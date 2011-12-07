class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :operator_panel_links
  
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
private
  def operator_panel_links
    []
  end
end
