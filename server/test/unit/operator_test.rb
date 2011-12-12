require 'test_helper'

class OperatorTest < ActiveSupport::TestCase
  test "test name is required" do
    assert !Operator.new(:email => "test@bar.de", :name => "", :password => "password").save
  end
  
  test "deletion of operator deletes all depending data" do
  end
end
