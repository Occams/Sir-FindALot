require 'test_helper'

class ParkingplaneTest < ActiveSupport::TestCase
  test "if added new lots to plane lots_total and lots_taken are correct" do
    flunk
  end
  
  test "sort_down works" do
    planes = Parkingplane.all
    planes_new = planes.rotate
    Parkingplane.sort_down(planes_new)
    
    p = Parkingplane.all
    assert_equal p.first, planes_new.first
  end
end
