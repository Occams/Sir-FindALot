require 'test_helper'

class Api::ParkinglotsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @lot = parkinglots(:one)
  end
  
  test "toggle lot taken" do
    operator = @lot.parkingplane.parkingramp.operator
    operator.reset_authentication_token!
    
    get :show, :id => @lot.id, :taken => !@lot.taken, :auth_key => operator.authentication_token
    assert_equal Parkinglot.find(@lot.id).taken, !@lot.taken
  end
  
  test "toggle lot taken is not allowed with wrong authkey" do
    operator = @lot.parkingplane.parkingramp.operator
    operator.reset_authentication_token!
    
    get :show, :id => @lot.id, :taken => !@lot.taken, :auth_key => operator.authentication_token+"dsfd"
    assert_equal Parkinglot.find(@lot.id).taken, @lot.taken
  end
end
