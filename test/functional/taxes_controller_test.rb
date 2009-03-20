require 'test_helper'

class TaxesControllerTest < ActionController::TestCase
  context "on GET to show" do
    setup do
      get :show
    end

    should_respond_with :success
    should_render_template "show"
    should_not_set_the_flash
  end
end
