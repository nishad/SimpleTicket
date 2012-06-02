class Admin::MainController < Admin::BaseController
  
  def index
    redirect_to :controller => "tickets", :action => "index"
  end

end
