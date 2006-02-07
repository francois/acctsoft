require File.dirname(__FILE__) + '/../test_helper'
require 'transactions_controller'

# Re-raise errors caught by the controller.
class TransactionsController; def rescue_action(e) raise e end; end

class TransactionsControllerTest < Test::Unit::TestCase
  def setup
    @controller = TransactionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
