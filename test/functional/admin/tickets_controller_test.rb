require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/tickets_controller'

# Re-raise errors caught by the controller.
class Admin::TicketsController; def rescue_action(e) raise e end; end

class Admin::TicketsControllerTest < Test::Unit::TestCase
  fixtures :users, :companies, :statuses
  def setup
    @controller = Admin::TicketsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    # @request.session[:user] = users('system_admin')
  end
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_index
    login_as_engineer
    get :index
    assert_redirected_to :action => 'list_pending'
  end
  
  def test_new
    login_as_engineer
    get :new
    assert_rendered_file 'new'
  end
  
  def test_create
    login_as_engineer
    body = "submitting ticket in test"
    subject = "test subject, while testing"
    get :create, :body => body, :subject => subject, :prority_id => 1, :user_id => 5, :take_it => true
    ticket = Ticket.find(:first, :order => "created_at DESC")
    assert_equal body, ticket.body
    assert_equal subject, ticket.subject
    assert_equal Status.find_by_name('Pending'), ticket.status
    assert_equal ticket.engineer_id, session[:user].id
  end
end
