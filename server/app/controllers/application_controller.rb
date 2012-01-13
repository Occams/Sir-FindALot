class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :detect_browser

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
protected
  def ismobile
    agent = request.headers["HTTP_USER_AGENT"].downcase
    MOBILE_BROWSERS.each do |m|
      return true if agent.match(m)
    end
    return false # set to false if you want to see website TODO!
  end
  
private
  MOBILE_BROWSERS = ["android", "ipod", "opera mini", "blackberry", "palm","hiptop","avantgo","plucker", "xiino","blazer","elaine", "windows ce; ppc;", "windows ce; smartphone;","windows ce; iemobile", "up.browser","up.link","mmp","symbian","smartphone", "midp","wap","vodafone","o2","pocket","kindle", "mobile","pda","psp","treo"]

  def detect_browser
    if ismobile
      return "mobile"
    else
      return "application"
    end
  end
end
