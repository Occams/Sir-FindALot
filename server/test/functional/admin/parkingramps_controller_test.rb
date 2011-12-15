require 'test_helper' unless Spork.using_spork?

class Admin::ParkingrampsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @parkingramp = parkingramps(:one)
    @operator = operators(:unipassau)
    sign_in @operator
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:parkingramps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create parkingramp" do
    assert_difference('Parkingramp.count') do
      post :create, parkingramp: @parkingramp.attributes
    end

    assert_redirected_to admin_parkingramps_path()
  end

  test "should get edit" do
    get :edit, id: @parkingramp.to_param
    assert_response :success
  end

  test "should update parkingramp" do
    put :update, id: @parkingramp.to_param, parkingramp: @parkingramp.attributes
    assert_redirected_to admin_parkingramps_path()
  end

  test "should destroy parkingramp" do
    assert_difference('Parkingramp.count', -1) do
      delete :destroy, id: @parkingramp.to_param
    end

    assert_redirected_to admin_parkingramps_path
  end
  
  test "index should only display the current operator's ramps" do
    get :index
    ramps = Parkingramp.find_all_by_operator_id(@operator.id)
    assert_equal Set.new(ramps), Set.new(assigns(:parkingramps))
  end
  
  test "edit should only display the current operator's ramps" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :edit, id: parkingramps(:three).id
    end
  end
  
  test "create should overwrite the operator to current operators" do
    @parkingramp.operator_id = @operator.id+1
    post :create, parkingramp: @parkingramp.attributes
    
    assert_equal @operator.id, Parkingramp.find(@parkingramp.id).operator_id
  end
  
  test "update should only happen if the ramp's operator is the current one" do
    not_my_ramp = parkingramps(:three)
    
    assert_raises(ActiveRecord::RecordNotFound) do
      put :update, id: not_my_ramp.to_param, parkingramp: not_my_ramp.attributes
      puts "oidnf"
    end
  end
end
