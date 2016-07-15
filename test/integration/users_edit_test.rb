require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
  	log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { username: "michael",
                                    email: "foo@invalid",
                                    password:              "foo",
                                    password_confirmation: "bar" }
    assert_redirected_to root_url
  end


  test "successful edit" do
  	log_in_as(@user)  	
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = "Michael_Example"
    email = "foo@bar.com"
    patch user_path(@user), user: { username: name,
                                    email: email,
                                    password:              "",
                                    password_confirmation: "",
                                    pass_prompt: "password" }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name.downcase,  @user.username
    assert_equal email, @user.email
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name  = "Michael_Example"
    email = "foo@bar.com"
    patch user_path(@user), user: { username:  name,
                                    email: email,
                                    password:              "",
                                    password_confirmation: "",
                                    pass_prompt: "password" }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name.downcase,  @user.username
    assert_equal email, @user.email
  end

end