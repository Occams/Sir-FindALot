require 'test_helper'

class ParkingrampsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @parkingramp = parkingramps(:one)
  end

  test "should return json values when showing a ramp" do
    get :show, {:id => @parkingramp.id, :format => :json}
    assert_not_nil assigns(:parkingramp)
  end
end
