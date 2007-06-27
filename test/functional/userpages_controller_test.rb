require File.dirname(__FILE__) + '/../test_helper'
require 'userpages_controller'

# Re-raise errors caught by the controller.
class UserpagesController; def rescue_action(e) raise e end; end

class UserpagesControllerTest < Test::Unit::TestCase
  def setup
    @controller = UserpagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
