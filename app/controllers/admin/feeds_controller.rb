class Admin::FeedsController < Admin::BaseController
  skip_before_filter  :check_admin_authentication
  session :off
  requires_authentication :using => :feed_auth_required
  
  def list_pending
    @tickets = Ticket.find(:all, :conditions => 'status_id IN (1,3)',
                                 :order => 'created_at DESC')
    flash[:action_name] = action_name.gsub('_feed','')                                
    render_without_layout :action => "feed"
  end

  def list_my_tickets
    @tickets = Ticket.find(:all, :order => 'created_at DESC',:conditions => ['status_id IN (1, 2, 3) AND engineer_id = ?', @user])
    @expand = true
    flash[:action_name] = action_name.gsub('_feed','')
    expires_now                           
    render_without_layout :action => "feed"
  end
  
  def list_all
    @tickets = Ticket.find(:all, :order => 'tickets.created_at DESC',
                                 :limit => 50,
                                 :include => [:user, :engineer])
     flash[:action_name] = action_name.gsub('_feed','')                                
     render_without_layout :action => "feed"
  end
  
private
  # This is for the RSS Feeds
  def feed_auth_required(email, password)
    begin
      @user = Engineer.authenticate(email, password).id
      return true
    rescue AuthenticationError => e
      return false
    end
  end
end
