require 'test_helper'

class Admin::ParkingplanesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @parkingramp = parkingramps(:one)
    @parkingplane = parkingplanes(:one)
    @operator = operators(:unipassau)
    sign_in @operator
  end

  test "should get new" do
    get :new, :parkingramp_id => @parkingramp.id
    assert_response :success
  end

  test "should create parkingplane" do
    assert_difference('Parkingplane.count') do
      post :create, parkingplane: @parkingplane.attributes, :parkingramp_id => @parkingramp.id
    end

    assert_redirected_to edit_admin_parkingramp_parkingplane_path(@parkingramp, assigns(:parkingplane))
  end

  test "should get edit" do
    get :edit, id: @parkingplane.to_param, :parkingramp_id => @parkingramp.id
    assert_response :success
  end

  test "should update parkingplane" do
    put :update, id: @parkingplane.to_param, parkingplane: @parkingplane.attributes, :parkingramp_id => @parkingramp.id
    assert_redirected_to edit_admin_parkingramp_parkingplane_path(@parkingramp, assigns(:parkingplane))
  end

  test "should destroy parkingplane" do
    assert_difference('Parkingplane.count', -1) do
      delete :destroy, id: @parkingplane.to_param, :parkingramp_id => @parkingramp.id
    end

    assert_redirected_to admin_parkingramps_path()
  end
  
  test "should only edit planes that are associated to one of the current_operator's ramps" do
    flunk
  end
  
  test "should only render new if the current ramp is one of current_operator's ramps" do
    flunk
  end
  
  test "should overwrite parkingramp_id when creating" do
    not_my_ramp = parkingramps(:three)
    @parkingplane.parkingramp_id = not_my_ramp.id
    
    assert_difference('Parkingplane.count') do
      post :create, parkingplane: @parkingplane.attributes, :parkingramp_id => @parkingramp.id
    end
    
    assert_equal @parkingramp.id, Parkingplane.find(@parkingplane.id).parkingramp_id
  end
  
  test "should check for operator is allowed for updating a plane" do
    flunk
  end
end
