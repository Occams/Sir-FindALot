class PagesController < ApplicationController
  # home, all others are handles within show
  def index
  end

  def show
    allowed = %w{impressum about help imprint api}
  
    if allowed.include?(params[:id].to_s)
      if self.respond_to?(params[:id])
        self.send(params[:id])
      else
        render :template => "pages/#{params[:id]}"
      end
    else
      not_found
    end
  end
end
