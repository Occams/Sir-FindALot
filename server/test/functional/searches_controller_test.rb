require 'test_helper'

class SearchesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should return json values when creating a search" do
    xhr :post, :create, {}
    assert_not_nil assigns(:parkingramps)
  end
  
end
