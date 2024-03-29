require 'test_helper'

class UsersControllerTest < ActionController::TestCase
 def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, username: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, username: @user, user: { username: @user.username, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get :edit, username: @user
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch :update, username: @user, user: { username: @user.username, email: @user.email }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect index when not logged in" do
  	get :index
  	assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, username: @user
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete :destroy, username: @user
    end
    assert_redirected_to root_url
  end  

  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch :update, username: @other_user, user: { password:              "password",
                                            password_confirmation: "password",
                                            admin: true }
    assert_not @other_user.reload.admin?
  end

  test "should redirect tracking when not logged in" do
    get :tracking, username: @user
    assert_redirected_to login_url
  end

  test "should redirect trackers when not logged in" do
    get :trackers, username: @user
    assert_redirected_to login_url
  end  
end
