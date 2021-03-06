class ApplicationController < ActionController::Base
  protect_from_forgery

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
  def mobile
    render :nothing, :layout => :mobile
  end
  
  def after_sign_in_path_for(resource)
    admin_parkingramps_url
  end
  
protected
  def ismobile
    agent = request.headers["HTTP_USER_AGENT"].downcase
    MOBILE_BROWSERS.each do |m|
      return true if agent.match(m)
    end
    return false
  end
end
