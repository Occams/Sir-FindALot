require 'test_helper'

class Admin::ParkinglotsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  setup do
    @parkingramp = parkingramps(:one)
    @parkingplane = parkingplanes(:one)
    @parkinglot = parkinglots(:one)
    @operator = operators(:unipassau)
    sign_in @operator
  end

  test "should create lot" do
    @parkinglot.x = 100
    assert_difference("Parkinglot.count") do
      post :create, parkinglot: @parkinglot.attributes, :parkingramp_id => @parkingramp.id, :parkingplane_id => @parkingplane.id
    end
  end
  
  test "should create buch of lots" do
    @lot1 = parkinglots(:one)
    @lot2 = parkinglots(:two)
    @lot1.x = 100
    @lot2.x = 101
    
    assert_difference("Parkinglot.count", 2) do
      post :create, :parkinglot => [@lot1.attributes, @lot2.attributes], :parkingramp_id => @parkingramp.id, :parkingplane_id => @parkingplane.id
    end
  end
  
  test "should update single lot" do
    @parkinglot.x = 100
    put :update, id: @parkinglot.to_param, parkinglot: @parkinglot.attributes, :parkingramp_id => @parkingramp.id, :parkingplane_id => @parkingplane.id
    
    assert_equal @parkinglot.x, Parkinglot.find(@parkinglot.id).x
  end
  
  test "should update bunch of lots" do
    @lot1 = parkinglots(:one)
    @lot2 = parkinglots(:two)
    @lot1.x = 100
    @lot2.x = 101
    
    put :update, :parkinglot => [@lot1.attributes, @lot2.attributes], :parkingramp_id => @parkingramp.id, :parkingplane_id => @parkingplane.id, :id => @lot1.to_param
    
    assert_equal @lot1.x, Parkinglot.find(@lot1.id).x
    assert_equal @lot2.x, Parkinglot.find(@lot2.id).x
  end
  
  test "should destroy single lot" do
    assert_difference('Parkinglot.count', -1) do
      delete :destroy, id: @parkinglot.to_param, :parkingramp_id => @parkingramp.id, :parkingplane_id => @parkingplane.id
    end
  end
  
  test "destroy bunch of lots" do
    @lot1 = parkinglots(:one)
    @lot2 = parkinglots(:two)
    assert_difference('Parkinglot.count', -2) do
      delete :destroy, :id => [@lot1.to_param, @lot2.to_param].join(","), :parkingramp_id => @parkingramp.id, :parkingplane_id => @parkingplane.id
    end
  end
end
