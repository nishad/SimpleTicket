class AccountController < ApplicationController
  skip_before_filter :check_user_authentication, :except => ['logout', 'edit', 'update']

  def login
    if request.post?
      begin
        session[:user] = User.authenticate(params[:employee][:email], params[:employee][:password]).id
        redirect_to :controller => 'tickets', :action => 'list_open'
      rescue AuthenticationError => e
        flash[:warning] = "#{e}"
      end
    end
  end

  def logout
    session[:user] = nil
    redirect_to :action => "login"
  end
  
  def edit
    @user = User.find(session[:user])
  end
  
  def update
    @user = User.find(params[:id])
    if params[:password] == params[:password1]
      @user.password = params[:password]
      @user.save
      redirect_to :controller => "tickets" and return if @user.update_attributes(params[:user])
    else
      redirect_to :action => "edit"
    end
  end
  
  def create
    if request.post?
      @emp = Employee.new(params[:employee])
      @emp.text_password = params[:employee][:password]
      @company = Company.find_by_maildomain(@emp.email.split("@").last)
      if @company && @emp.save
        @company.employees << @emp
        # TODO: flash messages should be replace to handle notification better. ask: alexl
        UserAccountMailer.deliver_after_signup(@emp)
        flash[:notice] = "Success. You can singin now."
      else
        flash[:warning] = "Failed, required fields can't be empty."
      end
      redirect_to :action => "login"
    end
  end
end
