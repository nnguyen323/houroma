require 'test_helper'

class TrackingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end

  test "tracking page" do
    get tracking_user_path(@user)
    assert_not @user.tracking.empty?
    assert_match @user.tracking.count.to_s, response.body
    @user.tracking.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "trackers page" do
    get trackers_user_path(@user)
    assert_not @user.trackers.empty?
    assert_match @user.trackers.count.to_s, response.body
    @user.trackers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "should track a user the standard way" do
    assert_difference '@user.tracking.count', 1 do
      post relationships_path, tracked_id: @other.id
    end
  end

  test "should track a user with Ajax" do
    assert_difference '@user.tracking.count', 1 do
      xhr :post, relationships_path, tracked_id: @other.id
    end
  end

  test "should untrack a user the standard way" do
    @user.track(@other)
    relationship = @user.active_relationships.find_by(tracked_id: @other.id)
    assert_difference '@user.tracking.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should untrack a user with Ajax" do
    @user.track(@other)
    relationship = @user.active_relationships.find_by(tracked_id: @other.id)
    assert_difference '@user.tracking.count', -1 do
      xhr :delete, relationship_path(relationship)
    end
  end  
end