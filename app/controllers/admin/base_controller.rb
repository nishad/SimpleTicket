require "feed_tools"
class Admin::BaseController < ApplicationController

  layout 'admin/application'
  skip_before_filter   :check_user_authentication
  before_filter        :check_admin_authentication
  
  def check_admin_authentication
    begin
      unless session[:user] && User.find(session[:user]).class.ancestors.include?(Engineer)
        redirect_to :controller => "login", :action => "index"
      end
    rescue
    end
  end
  
  def check_engineer_rights
    begin
      if current_engineer.role.name == "Engineer" and params[:controller] == "admin/statistics"
        flash[:notice] = "Can't go there!"
        redirect_to :controller => 'tickets', :action => 'list_pending'
      else
        true
      end
    rescue ActiveRecord::RecordNotFound => e
      session[:user] = nil
    end
  end

end
