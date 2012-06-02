require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/statistics_controller'

# Re-raise errors caught by the controller.
class Admin::StatisticsController; def rescue_action(e) raise e end; end

class Admin::StatisticsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::StatisticsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
