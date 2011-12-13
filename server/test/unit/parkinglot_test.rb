require 'test_helper'

class ParkinglotTest < ActiveSupport::TestCase
  test "uniqueness of position given by x,y" do
    lot = parkinglots(:one)
    
    assert_raise ActiveRecord::StatementInvalid do
      assert_false Parkinglot.create(lot.attributes)
    end
  end
  
  test "changing taken attribute adjusts lots_taken attr of plane" do
    @lot = parkinglots(:one)
    
    taken_lots_on_plane = @lot.parkingplane.lots_taken
    @lot.taken = !@lot.taken
    @lot.save
    
    assert_equal taken_lots_on_plane + (@lot.taken ? 1 : -1), @lot.parkingplane.lots_taken
  end
  
  test "adding and destroying lots adjusts lots_total and lots_taken attr of plane" do
    @lot = Parkinglot.new(parkinglots(:one).attributes)
    @lot.x += 20
    
    taken_lots_on_plane = @lot.parkingplane.lots_taken
    total_lots_on_plane = @lot.parkingplane.lots_total
    @lot.save
    
    assert_equal total_lots_on_plane + 1, @lot.parkingplane.lots_total
    assert_equal taken_lots_on_plane + (@lot.taken ? 1 : 0), @lot.parkingplane.lots_taken
    
    @lot.destroy
    assert_equal total_lots_on_plane, @lot.parkingplane.lots_total
    assert_equal taken_lots_on_plane, @lot.parkingplane.lots_taken
  end
end
