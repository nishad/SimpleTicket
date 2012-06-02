class TicketsController < ApplicationController

  def list_open
    @tickets = Ticket.find(:all, :include => [:engineer], :conditions => ["status_id != ? AND user_id = ?",4,session[:user]])
    @options = {
      :title=> 'View Open Tickets',
      :open=>'close',
      :detail=>'Ticket Detail',
      :button=>'btn-updateTicket.gif',
      :status => 4 }
  end

  def list_closed
  @ticket_pages, @tickets = paginate(:tickets, :per_page => 20, :include => [:engineer], :conditions => ["status_id = ? AND user_id = ?",4,session[:user]])
    # @tickets = Ticket.find(:all, :include => [:engineer], :conditions => ["status_id = ? AND user_id = ?",4,session[:user]])
  @options = {
      :title=> 'View Closed Tickets',
      :open=>'re-open',
      :detail=>'Closed Ticket Detail',
      :button=>'btn-createTicket.gif',
      :status => 1 }
    render :action => "list_open"
  end

  def list_company_all
  @ticket_pages, @tickets = paginate(:tickets, :per_page => 20, :include => [:user], :conditions => ["status_id != 4 and company_id = ?",current_user.company_id], :order => 'tickets.id desc')
    # @tickets = Ticket.find(:all, :include => [:engineer], :conditions => ["status_id = ? AND user_id = ?",4,session[:user]])
  @options = {
      :title=> 'View Company Tickets',
      :open=>'re-open',
      :detail=>'Ticket Details',
      :button=>'btn-updateTicket.gif',
      :status => 4 }
    render :action => "list_company"
  end

  def create
    @ticket = Ticket.new(params[:ticket])
    @ticket.user = User.find(session[:user])
    @ticket.status_id = 1
    @ticket.status = Status.find_by_name("Pending")
    if @ticket.save
      render :update do |page|
        page.redirect_to :action => 'list_open'
      end
    else
      notice = ["Can't save ticket..."]
      @ticket.errors.full_messages.each do |message|
        notice << "#{message},"
      end
      notice << "before submitting ticket"
      render :update do |page|
        page.alert notice.join("\n")
      end
    end
  end
  
  def toggle_ticket
    @ticket = Ticket.find(params[:id])
    case @ticket.status.name
    when "Closed"
      @ticket.status = Status.find_by_name('Open')
    else
      @ticket.status = Status.find_by_name('Closed')
    end
    if @ticket.save
      redirect_to :action => "list_open"
    end
  end

  def update_ticket
    if action_name == "list_open"
      redirect = "list_closed"
    else
      redirect = "list_open"
    end
    if !params[:comment].blank?
    @ticket = Ticket.find(params[:id])
      ticket_update = TicketUpdate.new(:comment => params[:comment],
                                       :ticket_id => @ticket.id, :user_id  => session[:user], :time_spent => params[:time_spent])
      # Ticket non only updated, but closed or re-opened, redirect
      if !params[:status].blank?
        @ticket.status_id = params[:status]
        @ticket.save
      else
        if @ticket.engineer
          @ticket.status_to_open
        else
          @ticket.status_to_close
        end
      end
      # Saving the ticket_update
      if ticket_update.save
        NotificationMailer.deliver_notified(@ticket.engineer.email,
                                            "Update Ticket",
                                            current_user.full_name,
                                            @ticket.engineer.full_name,
                                            ticket_update,
                                            params[:comment]
                                           )
      end
    end
    # redirecting if ticket´s status was changed
      if !params[:status].blank?
        redirect_to :controller => 'tickets', :action => redirect
      else
        redirect_to :controller => 'tickets', :action => 'list_open'
      end
  end

  def history
    @ticket = Ticket.find(params[:id])
    render :layout => false
  end

  def escalate
    render :layout => false
  end

end
