class Admin::PagesController < Admin::ApplicationController
  # home, all others are handles within show
  def index
  end

  def show
    allowed = %w{api}
  
    if allowed.include?(params[:id].to_s)
      if self.respond_to?(params[:id])
        self.send(params[:id])
      else
        render :template => "admin/pages/#{params[:id]}"
      end
    else
      not_found
    end
  end
end
