class ApplicationController < ActionController::Base
  before_filter :check_user_authentication

  def index
    render :text => 'w00t', :status => '404 Not Found'
  end
  
  def paginate_collection(collection, options = {})
      default_options = {:per_page => 10, :page => 1}
      options = default_options.merge options

      pages = Paginator.new self, collection.size, options[:per_page], options[:page]
      first = pages.current.offset
      last = [first + options[:per_page], collection.size].min
      slice = collection[first...last]
      return [pages, slice]
  end

protected
  def current_engineer
    Engineer.find(session[:user])
  end
  
  def current_user
    Employee.find(session[:user])
  end

  def check_user_authentication
    unless session[:user]
      redirect_to :controller => 'account', :action => 'login'
    end
  end

  # This is for the RSS Feeds
  def basic_auth_required(realm='Feed Password', error_message="Couldn't authenticate you")
    username, passwd = get_auth_data
    # check if authorized
    # try to get user
    unless session[:engineer] = Engineer.authenticate(username, passwd).id
      # the user does not exist or the password was wrong
      headers["Status"] = "Unauthorized"
      headers["WWW-Authenticate"] = "Basic realm=\"#{realm}\""
      render :text => error_message, :status => '401 Unauthorized'
    end
  end

  # This is for the RSS Feeds too
  def get_auth_data
    user, pass = '', ''
    # extract authorisation credentials
    if request.env.has_key? 'X-HTTP_AUTHORIZATION'
      # try to get it where mod_rewrite might have put it
      authdata = request.env['X-HTTP_AUTHORIZATION'].to_s.split
    elsif request.env.has_key? 'HTTP_AUTHORIZATION'
      # this is the regular location
      authdata = request.env['HTTP_AUTHORIZATION'].to_s.split
    end

    # at the moment we only support basic authentication
    if authdata and authdata[0] == 'Basic'
      user, pass = Base64.decode64(authdata[1]).split(':')[0..1]
    end
    return [user, pass]
  end

  def log_action_name
    # We log the action name for the ticket updater (TicketUpdateController) to know where to go after update
    #flash[:action_name] = action_name
  end
end