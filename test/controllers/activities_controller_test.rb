require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase

  def setup
    @activity = activities(:orange)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Activity.count' do
      post :create, activity: { content: "Lorem ipsum" }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Activity.count' do
      delete :destroy, id: @activity
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy for wrong activity" do
    log_in_as(users(:michael))
    activity = activities(:ants)
    assert_no_difference 'Activity.count' do
      delete :destroy, id: activity
    end
    assert_redirected_to root_url
  end

  # test "should redirect on update for wrong active activity" do
  #   log_in_as(users(:michael))
  #   assert_difference 'Actrait.count', 1 do
  #     patch :update, id: @activity, activity: @activity.attributes
  #   end
  #   assert_redirected_to root_url
  # end  
end