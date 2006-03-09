require File.dirname(__FILE__) + '/../test_helper'
require 'lookup_controller'

# Re-raise errors caught by the controller.
class LookupController; def rescue_action(e) raise e end; end

class LookupControllerTest < Test::Unit::TestCase
  def setup
    @controller = LookupController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
