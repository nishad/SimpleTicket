class Admin::TicketUpdateController < Admin::BaseController
#  before_filter :check_engineer_authentication

  def new
    # These are the instance variables needed for a ticket_update
    # They aren't in use as the ticket_updates are initialized on the tickets listing pages
#    @actions = Action.find(:all)
#    @ticket_update = Ticket.find(params[:id])
#    @engineers = Engineer.find(:all)
#    @priorities = Priority.find(:all)
#    @statuses = Status.find(:all)
  end

  def create
    # This is the ticket that's getting updated
    @ticket = Ticket.find(params[:id])
    # If the ticket_update attributes comming in are the same as the original ticket
    # attributes, they are deleted from the params hash
    things_to_update = params[:update].delete_if {|key, value| @ticket[key] == value}
    # The attributes that have no value (not changed by the engineer) are deleted as well
    things_to_update = things_to_update.delete_if {|key, value| value == ""}
    # Creating the local journal variable as an Array
    journal = []
    # All this part is for the journal attribute of the ticket_update
    ### IT HAS BEEN DEACTIVATED FOR DISTRIBUTION BUT IT FULLY WORKS IF YOU WANT IT (just uncomment the 'journal <<' lines you want) ###
    # # Subject changement
    # journal << "Ticket subject has been changed to #{things_to_update[:subject]}" if things_to_update[:subject]
    # # Engineer reassignement
    # journal << "Ticket has been reassigned to #{Engineer.find(things_to_update[:engineer_id]).full_name}" if things_to_update[:engineer_id]
    # # Priority reevaluation
    # journal << "Ticket priority has been reevaluated to #{Priority.find(things_to_update[:priority_id]).name}" if things_to_update[:priority_id]
    # # Difficulty evaluation
    # journal << "Ticket difficulty has been evaluated to #{Difficulty.find(things_to_update[:difficulty_id]).name}" if things_to_update[:difficulty_id]
    # Comment (this is necessary - see TicketUpdate validations)
    journal << "#{things_to_update[:comment]}" if things_to_update[:comment]
    # # Time spent (this is necessary - see TicketUpdate validations)
    # journal << "#{things_to_update[:time_spent]} minutes spent on this update" if things_to_update[:time_spent]

    # ANY update to ticket will take out of pending or contacted status
    @ticket.status_id = 2

    # This is the pretty straight forward way to react to the action field
    case Action.find(things_to_update[:action_id]).name
      when 'Update Ticket'
        flash[:notice] = "Ticket successfully updated."
        # If there is a reassignment it overrides the default action
        things_to_update[:action_id] = Action.find_by_name('Reassigned').id if things_to_update[:engineer_id]
      when 'Move to Contacted'
        @ticket.status_id = 3 # Ticket status goes to contacted
        # journal << "Ticket has been moved to Contacted"
        flash[:notice] = "Ticket updated and moved to Contacted."
        # If there is a reassignment it overrides the default action
        things_to_update[:action_id] = Action.find_by_name('Reassigned').id if things_to_update[:engineer_id]
      when 'Move to Schedule On-Site'
        # journal << "Ticket has been moved to Schule On-Site"
        flash[:notice] = "Ticket updated and moved to Schule On-Site."
        # If there is a reassignment it overrides the default action
        things_to_update[:action_id] = Action.find_by_name('Reassigned').id if things_to_update[:engineer_id]
      when 'Close Ticket'
        @ticket.status_id = 4 # Ticket status goes to closed
        # journal << "Ticket has been Closed"
        flash[:notice] = "Ticket updated and successfully Closed."
    end

    # we join the journal Array together with the HTML <br /> tag
    journal = journal.join(". <br />")

    # The TicketUpdate gets initialized with several attributes
    # The engineer attribute saves the engineer that really updating this ticket
    ticket_update = TicketUpdate.new( :user_id => session[:user],
                                      :action_id => things_to_update[:action_id],
                                      :time_spent => things_to_update[:time_spent],
                                      :comment => journal,
                                      :file => things_to_update[:file])
    # Saving the ticket_update
    if ticket_update.save

      # mail notification - ticket was opened
      if params[:notify]
        subj = Action.find(things_to_update[:action_id]).name
        engineer = Engineer.find(session[:user]).full_name
        user = User.find_by_id(@ticket.user_id).full_name
        email = User.find_by_id(@ticket.user_id).email
        ticket = @ticket
        if things_to_update[:action_id] == 4
          NotificationMailer.deliver_closed(email,subj,engineer,user,ticket_update)
        else
          NotificationMailer.deliver_notified(email,subj,engineer,user,ticket_update,journal)
        end
      end
      # end mail notification

      # Delete things from the ticket update hash that are not ticket attributes
      things_to_update.delete(:comment)
      things_to_update.delete(:action_id)
      things_to_update.delete(:time_spent)
      things_to_update.delete(:file)
      # Updating the attributes
      @ticket.update_attributes(things_to_update)
      # Adding the ticket update to the ticket
      @ticket.ticket_updates << ticket_update

      # Saving the ticket
      if @ticket.save
        # flash.discard(:notice)
        # # Rendering create.rjs
        # DEACTIVATED BEACAUSE OF UPLOADS OF FILES THROUGH AJAX NO DISTRUABLE (server issues)
        # update_init
        # render :action => 'create'
        redirect_to :controller => 'tickets', :action => flash[:action_name]
      else
        # This is if the ticket can't get saved (shouldn't happen much...)
        # Only one line of RJS so it stays inline
        redirect_to :controller => 'tickets', :action => flash[:action_name]
        # DEACTIVATED BEACAUSE OF UPLOADS OF FILES THROUGH AJAX NO DISTRUABLE (server issues)
        # render :update do |page|
        #   page.alert @ticket.errors.each_full { |msg| "#{msg} " }
        # end
      end
    else
      # This is if the ticket_update can't get saved (validation issue)
      # Only one line of RJS so it stays inline
      redirect_to :controller => 'tickets', :action => flash[:action_name]
      # DEACTIVATED BEACAUSE OF UPLOADS OF FILES THROUGH AJAX NO DISTRUABLE (server issues)
      # render :update do |page|
      #   page.alert ticket_update.errors.each_full { |msg| "#{msg} " }
      # end
    end
  end

  def view_history
    @ticket = Ticket.find(params[:id], :include => [{:user => :company}, :engineer])
    render_without_layout
  end

  def quick_update
    @ticket = Ticket.find(params[:id])
    # You can do a quick update if the ticket has already been updated during that day
    unless @ticket.updated_at >= Time.now.at_beginning_of_day
      # Initializing our ticket_update object
      ticket_update = TicketUpdate.new( :comment => "This ticket has been worked on by #{Engineer.find(session[:engineer])}",
                                        :engineer_id => session[:user],
                                        :time_spent => 5,
                                        :journal => "This ticket has been worked on by #{Engineer.find(session[:engineer])} (Quick update; time_spent: 5)")
      # Saving the ticket_update
      if ticket_update.save
        # Adding the ticket update to the ticket
        @ticket.ticket_updates << ticket_update
        # Saving the ticket
        if @ticket.save
          flash[:notice] = "Successfully updated..."
          flash.discard(:notice)
          # Rendering create.rjs
          update_init
          render :update do |page|
            page.hide "ticket_#{@ticket.id}_details", "ticket_#{@ticket.id}_update"
            # We show a flash notice
            # This is a helper method in ApplicationHelpers
            page.flash_notice(flash[:notice])
          end
        else
          # This is if the ticket can't get saved
          # Only one line of RJS so it stays inline
          render :update do |page|
            page.alert @ticket.errors.each_full { |msg| "#{msg} " }
          end
        end
      else
        # This is if the ticket_update can't get saved (shouldn't happen much...)
        #There can't be validation issues here, there can only be SQL server problems
        # Only one line of RJS so it stays inline
        render :update do |page|
          page.alert ticket_update.errors.each_full { |msg| "#{msg} " }
        end
      end
    else
      flash[:notice] = "You cannot apply a Quick Update to a ticket already updated today."
      render :update do |page|
        # We show a flash notice
        # This is a helper method in ApplicationHelpers
        page.flash_notice(flash[:notice])
      end
    end
  end
end
