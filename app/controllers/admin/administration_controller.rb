class Admin::AdministrationController < Admin::BaseController
  before_filter :check_engineer_rights
 
  def index
    redirect_to :action => 'engineers'
  end

  def engineers
    if current_engineer.role.name == 'Administrator'
      @engineer_pages, @engineers = paginate :engineers, :order => 'status, first_name, last_name'
    else
      @engineer_pages, @engineers = paginate :engineers, :order => 'first_name, last_name', :conditions => 'status = "Current"'
    end
  end
  
  def new_engineer
    @engineer = Engineer.new
    render_without_layout
  end
  
  def create_engineer
    # We initialize a new Engineer with the incoming params
    @engineer = Engineer.new(params[:engineer])
    # Saving the engineer
    if @engineer.save
      flash[:notice] = "Engineer successfully saved"
      # We manually discard the notice after this action as it doesn't discard
      # by himself with RJS
      flash.discard(:notice) 
      # Rendering create.rjs
      render :action => 'create_engineer'
    else
      # This happens if the ticket has problems getting saved (validations)
      # One line of RJS so it's inline
      render :update do |page|
        page.alert @engineer.errors.each_full { |msg| p " #{msg}" }
      end
    end
  end
  
  def edit_engineer
    @engineer = Engineer.find(params[:id])
    render_without_layout
  end
  
  def update_engineer
    # Fetching the Engineer to update with the incoming params
    @engineer = Engineer.find(params[:id])
    @engineer.attributes = params[:engineer]
    # We must manualy assign type. It won't understand otherwise as we are changing
    # the object's class and Ruby thinks it's not normal
    # ...Don't really need this anymore, better to use the engineer_type accessor methods
#    @engineer[:type] = params[:engineer][:engineer_type]
    # Updating the engineer attributes
    if @engineer.save
      # Reloading because to get the right data (object.reload won't work here )
      @engineer = Engineer.find(params[:id])
      flash[:notice] = "Engineer successfully updated"
      # We manually discard the notice after this action as it doesn't discard
      # by himself with RJS
      flash.discard(:notice) 
      # Rendering create.rjs
      render :action => 'update_engineer'
    else
      # This happens if the engineer has problems getting saved (validations)
      # One line of RJS so it's inline
      render :update do |page|
        page.alert @engineer.errors.each_full { |msg| p " #{msg}" }
      end
    end
  end
  
  def alerts_and_notices
    # render :text => 'comming soon'
  end
end
