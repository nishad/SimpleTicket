class Admin::TicketsController < Admin::BaseController
  #TODO: Kill filter/session for xml requests
  before_filter :basic_auth_required, :only => :list_my_tickets_feed
  before_filter :log_action_name
  before_filter :set_tdo, :except => ['list_pending', 'tdo','list_my_tickets']
  before_filter :load_blog_feed, :only => ['list_pending', 'list_my_tickets', 'list_all']

  def index
    redirect_to :action => 'list_pending'
  end

  def new
    # We create the instance methods for the Ticket creation form
    @ticket = Ticket.new
    @customers = Customer.find(:all, :order => 'name ASC')
    @priorities = Priority.find(:all)
    # The Ticket creation form comes in a JS window so we better not render the layout
    render_without_layout
  end

  def create
    # We simply initialize a new Ticket with the incoming params
    @ticket = Ticket.new( :body => params[:body],
                          :subject => params[:subject],
                          :priority_id => params[:priority_id],
                          :user_id => params[:user_id],
                          # 1 is pending status
                          :status_id => 1)

    # Assigning ticket to engineer and setting opening if "Take it" checked
    @ticket.engineer_id = session[:user] and @ticket.status_id = 2 if params[:take_it]

    if @ticket.save
      # RJS
      render :action => 'create'

      # mail notification - ticket was opened
      if params[:notify]
        engineer = Engineer.find(session[:user]).full_name
        user = User.find_by_id(@ticket.user_id).full_name
        email = User.find_by_id(@ticket.user_id).email
        ticket = @ticket
        subj = "ticket '#{@ticket.subject}' has been opened"
        NotificationMailer.deliver_opened(email,subj,engineer,user,ticket)
      end
    else
      notice = ["Can't save ticket..."]
      @ticket.errors.full_messages.each do |message|
        notice << "#{message},"
      end
      notice << "before submitting ticket."
      render :update do |page|
        page.alert notice.join("\n")
      end
    end
  end

  def list_pending
    unless request.xhr?
      session[:tdo] = []
    end

    # This view shows the pending and contacted tickets
    @tickets = Ticket.find(:all,:conditions => 'status_id IN (1,3)', :order => 'tickets.created_at DESC', :include => {:user=>:company})

    # TODO: this needs work in general
    # This function is called as well by plain HTML and JS when we are supposed to update the pending tickets list
    respond_to do |wants|
      wants.html { }
      wants.js { render :partial => 'ticket_table', :object => @tickets }
    end
  end

  def tdo
    if request.xhr?
      if session[:tdo].include?(params[:id].to_i)
        session[:tdo].delete(params[:id].to_i)
      else
        session[:tdo] = session[:tdo] << params[:id].to_i
      end
      render :text => "#{session[:tdo]}"
    end
  end

  def take_ticket
    # We find the ticket passed as a get param
    @ticket = Ticket.find(params[:id])
    # We update the attributes
    if @ticket.update_attributes(:engineer_id => session[:user], :status_id => 2)
      # This little piece of javascript will be loaded onLoad on the body HTMl tag - see layouts/admin/application
      flash[:javascript] = "Element.show('ticket_#{@ticket.id}_details');Element.show('ticket_#{@ticket.id}_update'); Element.setStyle('ticket_#{@ticket.id}', {cursor:'default'} );"
      flash[:ticket_taken] = @ticket.id
      redirect_to :action => 'list_my_tickets'
    else
      render :update do |page|
        page.alert ticket.errors.each_full { |msg| "#{msg} " }
      end
    end
  end

  def list_my_tickets
    unless request.xhr?
      session[:tdo] = []
      session[:tdo] << flash[:ticket_taken].to_i if flash[:ticket_taken]
    end
    @tickets = Ticket.find(:all, :order => 'tickets.created_at DESC',:conditions => ['status_id IN (1, 2, 3) AND engineer_id = ?', session[:user]], :include => {:user=>:company})
    respond_to do |wants|
      wants.html { }
      wants.js { render :partial => 'ticket_table', :object => @tickets }
    end
  end
  
  def reset_filters
    session[:search_params] = nil
    redirect_to :action => "list_all"
  end

  def list_all
    if request.xhr? or !session[:search_params].blank?
      search
      unless @search_query.blank?
      @ticket_pages, @tickets = paginate :tickets, :order => 'tickets.created_at DESC', :conditions => "#{@search_query}", :include => [:ticket_updates, {:user=>:company}, :engineer]
      end
    end
    unless @tickets
      @ticket_pages, @tickets = paginate :tickets,  :order => 'tickets.created_at DESC', :include => [:engineer, {:user=>:company}, :status]
    end
    # escaping html GET query
    respond_to do |wants|
      wants.html { render :action => 'list_all' }
      wants.js { render :partial => 'ticket_table', :object => @tickets }
    end
  end

  def search
    if request.xhr?
      search_params = params if params
    else
      search_params = session[:search_params] if params
    end

    if search_params
      @search_query = Ticket.search(search_params)
    end
    session[:search_params] = search_params
  end
  
protected
  def set_tdo
    session[:tdo] = []
  end
    
  def load_blog_feed
    if ($feed_age ||= Time.now) < 30.minutes.ago
      $blog_feed = nil
      $feed_age = Time.now
    end
    $blog_feed ||= FeedTools::Feed.open('http://news.architel.com/feed/')
    @feed_age = $feed_age
    @blog_feed = $blog_feed
  end
end
