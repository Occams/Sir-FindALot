class Mobile::PagesController < Mobile::ApplicationController
  # home, all others are handles within show
  def index
  end

  def show
    allowed = %w{upgrade}
  
    if allowed.include?(params[:id].to_s)
      if self.respond_to?(params[:id])
        self.send(params[:id])
      else
        render :template => "mobile/pages/#{params[:id]}"
      end
    else
      not_found
    end
  end
end
