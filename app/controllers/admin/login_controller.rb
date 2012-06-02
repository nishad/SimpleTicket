class Admin::LoginController < Admin::BaseController
  skip_before_filter  :check_admin_authentication

  def index
    if request.post? 
      begin
        session[:user] = Engineer.authenticate(params[:email], params[:password]).id
        redirect_to :controller => 'tickets', :action => 'index'
     rescue AuthenticationError => e
       flash[:warning] = "#{e}"
      end
    else
      render :layout => "admin/login"
    end
  end
  
  def signout 
    session[:user] = nil 
    redirect_to :controller => 'tickets' 
  end 
end
