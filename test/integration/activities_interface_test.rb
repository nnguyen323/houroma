require 'test_helper'

class ActivitiesInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
    @user_activity = activities(:orange)
    @other_user_activity = activities(:ants)
  end

  test "activity interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    # Invalid action ID SUPPOSED TO BE A STRING M8
    assert_no_difference 'Activity.count' do
      post activities_path, activity: { content: "Hello" }
    end
    # Invalid submissions no action
    assert_no_difference 'Activity.count' do
      post activities_path, activity: { content: "huggaaa"}
    end


    # since we're using modal to generate form we moved error to a flash message for now... so commenting out this next line    
    # assert_select 'div#error_explanation'


    # Valid submission
    content = "This activity really ties the room #together"
    assert_difference 'Activity.count', 1 do
      post activities_path, activity: { content: content }
    end
    assert User.find_by_username("michael_example").active
    assert_equal 1, Action.last.live_users
    assert_equal 'together', Action.last.content

    assert_redirected_to "/lounges/#{Action.last.content}"
    follow_redirect!
    assert_match Action.last.content.capitalize, response.body


    # Delete a post.
    first_activity = @user.activities.paginate(page: 1).first

    assert_no_difference 'Activity.count' do
      delete activity_path(first_activity)
    end

    assert_equal 1, Action.last.live_users
    
    #so created at and finished at differ
    sleep 1

    # Try to patch an activity that is your own but is wrong one.
    activity_mine_but_wrong = activities(:orange)
    patch activity_path(activity_mine_but_wrong)
    assert_redirected_to root_url
    #should still be active
    assert User.find_by_username("michael_example").active

    #stop the current activity
    patch activity_path(first_activity)
    
    hello = Activity.find_by_action_id(first_activity.action_id)
    assert_equal 0, Action.last.live_users
    assert hello.finished_at > hello.created_at
    
    #make sure you can delete an activity
    assert_difference 'Activity.count', -1 do
      delete activity_path(Activity.find_by_action_id(first_activity.action_id))
    end

    # Visit a different user.
    get user_path(users(:archer))
    assert_select 'a', text: 'Delete', count: 0

    # Try to patch a different activity that's not your own
    activity_not_mine = activities(:ants)
    patch activity_path(activity_not_mine)
    assert_redirected_to root_url

    # Try to delete a different activity that's not yours
    assert_no_difference 'Activity.count' do
      delete activity_path(activities(:ants))
    end
  end

  test "rating activities" do
    log_in_as(@user)
    value = @other_user_activity.rating.value
    #create a rate
    assert_difference 'Rate.count', 1 do
      post rates_path, {rating_id: @other_user_activity.rating.id, up: 'true'}
    end
    assert_equal value + 1, Rate.last.rating.value

    #create same one again
    assert_no_difference 'Rate.count' do
      post rates_path, {rating_id: @other_user_activity.rating.id, up: 'true'}
    end
    assert_equal value + 1, Rate.last.rating.value

    #delete rate you just created
    assert_difference 'Rate.count', -1 do
      delete rate_path(Rate.last), {rating_id: @other_user_activity.rating.id}
    end

    assert_equal Rating.find(@other_user_activity.rating.id).value, value

    #delete same one again.........shouldn't do anything
    assert_no_difference 'Rate.count' do
      delete rate_path(Rate.last), {rating_id: @other_user_activity.rating.id}
    end

    #create the same
    assert_difference 'Rate.count', 1 do
      post rates_path, {rating_id: @other_user_activity.rating.id, up: 'true'}
    end
    assert_equal value + 1, Rate.last.rating.value

    #update to false
    assert_difference 'Rate.last.rating.value', -2 do
      patch rate_path(Rate.last)
    end

    assert_difference 'Rate.last.rating.value', 2 do
      patch rate_path(Rate.last)
    end

    #delete activity again.........
    rating_id = Rate.last.rating_id
    rate_id = Rate.last.id
    assert_difference 'Rating.find(rating_id).value', -1 do
        assert_difference 'Rate.count', -1 do
          delete rate_path(Rate.last), {rating_id: @other_user_activity.rating.id}
        end
    end

    #check if this affects rating how would it.............
    assert_difference 'Rating.find(rating_id).value', 0 do
      patch rate_path(rate_id)
    end

  end

  test "can't rate your own activity" do 
    log_in_as @user
    #if you can't create a rating that is your own..other cases should follow
    #create same one again this time your own activity
    assert_no_difference 'Rate.count' do
      post rates_path, {rating_id: @user_activity.rating.id, up: 'true'}
    end
    assert_redirected_to root_url
  end

  test "no redirect on activity creation" do
    log_in_as users(:lana)
    content = "going down the #railroad"
    assert_difference 'Activity.count', 1 do
      post activities_path, activity: { content: content }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body    
  end
end