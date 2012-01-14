class ApplicationController < ActionController::Base
  protect_from_forgery

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
  def mobile
    render :nothing, :layout => :mobile
  end
  
protected
  def ismobile
    agent = request.headers["HTTP_USER_AGENT"].downcase
    MOBILE_BROWSERS.each do |m|
      return true if agent.match(m)
    end
    return false # set to false if you want to see website TODO!
  end
end
