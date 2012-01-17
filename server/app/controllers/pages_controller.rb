class PagesController < ApplicationController
  # home, all others are handles within show
  def index
    if operator_signed_in?
      redirect_to admin_parkingramps_url
    end
  end

  def show
    allowed = %w{impressum about help imprint faq contact api demo}
    no_layout = %{demo}
  
    if allowed.include?(params[:id].to_s)
      if self.respond_to?(params[:id])
        self.send(params[:id])
      else
        render :template => "pages/#{params[:id]}", :layout => no_layout.include?(params[:id].to_s) ? false : "application"
      end
    else
      not_found
    end
  end
end
