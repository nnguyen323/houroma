require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  
  def setup
    @relationship = Relationship.new(tracker_id: 1, tracked_id: 2)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a tracker_id" do
    @relationship.tracker_id = nil
    assert_not @relationship.valid?
  end

  test "should require a tracked_id" do
    @relationship.tracked_id = nil
    assert_not @relationship.valid?
  end

end
