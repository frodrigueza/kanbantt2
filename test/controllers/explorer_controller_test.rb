require 'test_helper'

class ExplorerControllerTest < ActionController::TestCase
  test "should get tree_view" do
    get :tree_view
    assert_response :success
  end

end
