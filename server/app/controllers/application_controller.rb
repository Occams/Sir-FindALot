class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :operator_panel_links
  
  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
protected
  def setAccessControl
    access_controls = {
      "Access-Control-Allow-Origin" => "*",
      "Access-Control-Allow-Headers" => "X-Requested-With",
      "Access-Control-Max-Age" => "60",
      "Access-Control-Request-Method" => '*' 
    }
    access_controls.each do |k,v|
      headers[k] = v
    end
  end
  
private
  def operator_panel_links
    []
  end
end
