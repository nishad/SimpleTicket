require File.dirname(__FILE__) + '/../test_helper'
require 'tickets_controller'

# Re-raise errors caught by the controller.
class TicketsController; def rescue_action(e) raise e end; end

class TicketsControllerTest < Test::Unit::TestCase
  def setup
    @controller = TicketsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
